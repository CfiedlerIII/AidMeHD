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
  @EnvironmentObject var authManager: AuthManager
  @ObservedObject var viewModel: LoginViewModel<CloudService>
  @State var emailText: String = ""
  @State var passwordText: String = ""
  @State var errorMessage: String?
  let cloudService = CloudService.shared

  init(viewModel: LoginViewModel<CloudService>) {
    self.viewModel = viewModel
  }

  var body: some View {
    NavigationStack(path: $viewModel.path) {
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
            createNewUserWithEmailPassword()
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
            signInWithEmailPassword()
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
      .background(.mint)
      .navigationDestination(for: String.self) { value in
        if value == "AccountSetup" {
          AccountSetupView(showLoginSheet: $viewModel.showLoginSheet) // A view that takes a String
        } else {
          Text("Whoops! You shouldn't be here.")
        }
      }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.mint)
  }

  /// Sign in with Emal and Password, and authenticate with `Firebase`.
  func signInWithEmailPassword() {
    guard emailText.isValidEmail() else {
      let errorMessageText = "Email is invalid."
      self.errorMessage = errorMessageText
      print(errorMessageText)
      return
    }
    Auth.auth().signIn(withEmail: emailText, password: passwordText) { authResult, error in
      if let error = error as NSError? {
        let errorMessageText = "Error signing in: \(error.localizedDescription)"
        print("Error signing in: \(errorMessageText)")
        self.errorMessage = errorMessageText
        return
      }

      print("AuthSuccess: \(authResult!.user.uid)")
      self.viewModel.signIn(userId: authResult!.user.uid)
      viewModel.showLoginSheet = false
    }
  }

    func createNewUserWithEmailPassword() {
      guard emailText.isValidEmail() else {
        let errorMessageText = "Email is invalid."
        self.errorMessage = errorMessageText
        print(errorMessageText)
        return
      }
      viewModel.createNewUser(email: emailText, password: passwordText) { error in
        if let error = error {
          let errorMessageText = "Error creating user: \(error.localizedDescription)"
          self.errorMessage = errorMessageText
          print(errorMessageText)
        } else {
          print("AuthSuccess: \(String(describing: self.userId))")
        }
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
        viewModel.showLoginSheet = false
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
            viewModel.showLoginSheet = false
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
}

#Preview {
  LoginView(viewModel: LoginViewModel(dataService: CloudService.shared))
    .environmentObject(AuthManager())
}
