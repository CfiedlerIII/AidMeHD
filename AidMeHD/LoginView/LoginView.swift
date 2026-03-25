//
//  LoginView.swift
//  AuthLogin
//
//  Created by Marwa Abou Niaaj on 29/11/2023.
//

import AuthenticationServices
import GoogleSignInSwift
import SwiftUI
import FirebaseAuth

struct LoginView: View {
  @AppStorage("userId") var userId: String?
  @Environment(\.colorScheme) var colorScheme
  @Environment(\.dismiss) var dismiss
  @EnvironmentObject var authManager: AuthManager
  let cloudService = CloudService.shared
  @State var emailText: String = ""
  @State var passwordText: String = ""
  @State var errorMessage: String?

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Spacer()
        Text("AidMeHD")
          .font(.title)
          .fontWeight(.bold)
        Spacer()

        TextField("Email", text: $emailText)
          .padding()
          .background(.white)
          .frame(width: 280, height: 40, alignment: .center)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(errorMessage == nil ? .clear : .red, lineWidth: 2)
          )

        SecureField("Password", text: $passwordText)
          .padding()
          .background(.white)
          .frame(width: 280, height: 40, alignment: .center)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(errorMessage == nil ? .clear : .red, lineWidth: 2)
          )

        if let errorMessageText = errorMessage {
          Text(errorMessageText)
            .foregroundColor(.red)
        }

        Divider()

        // MARK: - Apple
        SignInWithAppleButton(
          onRequest: { request in
            AppleSignInManager.shared.requestAppleAuthorization(request)
          },
          onCompletion: { result in
            handleAppleID(result)
          }
        )
        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        .frame(width: 280, height: 40, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 8))

        // MARK: - Google
        GoogleSignInButton {
          Task {
            await signInWithGoogle()
          }
        }
        .frame(width: 280, height: 40, alignment: .center)
        .clipShape(RoundedRectangle(cornerRadius: 8))

        Divider()

        HStack {
          Button {
            runAccountWorkflow(isCreatingAccount: true)
          } label: {
            HStack {
              Spacer()
              Text("Create Account")
                .font(.body.bold())
              Spacer()
            }
            .frame(height: 45, alignment: .center)
            .padding(2)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
          }
          .disabled(emailText.isEmpty || passwordText.isEmpty)

          Button {
            runAccountWorkflow()
          } label: {
            HStack {
              Spacer()
              Text("Sign In")
                .font(.body.bold())
              Spacer()
            }
            .frame(height: 45, alignment: .center)
            .padding(2)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
          }
          .disabled(emailText.isEmpty || passwordText.isEmpty)
        }
        .frame(width: 280)

        Spacer()
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.mint)
    }
  }

  // Account sign-in workflow
  func runAccountWorkflow(isCreatingAccount: Bool = false) {
    guard emailText.isValidEmail() else {
      let errorMessageText = "Email is invalid."
      self.errorMessage = errorMessageText
      print(errorMessageText)
      return
    }
    guard passwordText.isEmpty else {
      let errorMessageText = "Password is required."
      self.errorMessage = errorMessageText
      print(errorMessageText)
      return
    }
    if isCreatingAccount {
      createNewUserWithEmailPassword(emailText, passwordText)
    } else {
      signInWithEmailPassword(emailText, passwordText)
    }
  }

  /// Sign in with Emal and Password, and authenticate with `Firebase`.
  func signInWithEmailPassword(_ email: String, _ password: String) {
    Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
      if let error = error as NSError? {
        let errorMessageText = "Error signing in: \(error.localizedDescription)"
        print("Error signing in: \(errorMessageText)")
        self.errorMessage = errorMessageText
        return
      }

      print("AuthSuccess: \(authResult!.user.uid)")
      self.userId = authResult!.user.uid
      dismiss()
    }
  }

  func createNewUserWithEmailPassword(_ email: String, _ password: String) {
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
      if let error = error as NSError? {
        if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
          return
        } else {
          // Handle other errors (e.g., invalid email, weak password, network issues)
          print("Error creating user: \(error.localizedDescription)")
          return
        }
      }
      print("AuthSuccess: \(authResult!.user.uid)")
      self.userId = authResult!.user.uid
      // User created successfully
      print("User created: \(authResult?.user.email ?? "")")
      Task {
        await cloudService.setNewUser(userId: authResult!.user.uid)
      }
      // Optionally, send a verification email
      authResult?.user.sendEmailVerification { error in
        // Handle verification email error or success
        if let error = error as NSError? {
          print("Error sending email verification: \(error.localizedDescription)")
        } else {
          print("Email verification successfully sent")
        }
      }
      dismiss()
    }
  }
  
  /// Sign in with `Google`, and authenticate with `Firebase`.
  func signInWithGoogle() async {
    do {
      guard let user = try await GoogleSignInManager.shared.signInWithGoogle() else { return }

      let result = try await authManager.googleAuth(user)
      if let result = result {
        print("GoogleSignInSuccess: \(result.user.uid)")
        self.userId = result.user.uid
        dismiss()
      }
    }
    catch {
      print("GoogleSignInError: failed to sign in with Google, \(error))")
      // Here you can show error message to user.
      return
    }
  }

  func handleAppleID(_ result: Result<ASAuthorization, Error>) {
    if case let .success(auth) = result {
      guard let appleIDCredentials = auth.credential as? ASAuthorizationAppleIDCredential else {
        print("AppleAuthorization failed: AppleID credential not available")
        return
      }

      Task {
        do {
          let result = try await authManager.appleAuth(
            appleIDCredentials,
            nonce: AppleSignInManager.nonce
          )
          if result != nil {
            self.userId = result?.user.uid
            dismiss()
          }
        } catch {
          print("AppleAuthorization failed: \(error)")
          // Here you can show error message to user.
        }
      }
    }
    else if case let .failure(error) = result {
      print("AppleAuthorization failed: \(error)")
      // Here you can show error message to user.
    }
  }

  /// Sign-in anonymously
  func signAnonymously() {
    Task {
      do {
        let result = try await authManager.signInAnonymously()
        print("SignInAnonymouslySuccess: \(result?.user.uid ?? "N/A")")
      }
      catch {
        print("SignInAnonymouslyError: \(error)")
      }
    }
  }
}

#Preview {
  LoginView()
    .environmentObject(AuthManager())
}
