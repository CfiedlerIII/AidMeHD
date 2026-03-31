//
//  HomeView.swift
//  AuthLogin
//
//  Created by Marwa Abou Niaaj on 29/11/2023.
//

import SwiftUI

struct HomeView: View {
  @EnvironmentObject var authManager: AuthManager
  @AppStorage("userId") var userId: String?
  @StateObject private var viewModel: TasksViewModel = .init(dataService: CloudService.shared)
  @StateObject private var loginViewModel: LoginViewModel = .init(dataService: CloudService.shared)
  @State private var showLoginSheet = false
  @State private var showDeleteAccountAlert = false

  init() {}

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        VStack(alignment: .leading) {
          if authManager.authState == .signedIn {
            Text("\(loginViewModel.user?.firstName ?? "") \(loginViewModel.user?.lastName ?? "")")
              .font(.headline)

            Text(authManager.user?.email ?? "Email placeholder")
              .font(.subheadline)
          }
          else {
            Text("Sign-in to view data!")
              .font(.headline)
          }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding()

        NavigationLink(destination: {
          UserSearchView()
        }, label: {
          Text("Users")
            .foregroundStyle(.black)
            .padding()
            .background(Color.white)
            .cornerRadius(12)
        })

        TaskListView(viewModel: viewModel)
          .overlay(
            RoundedRectangle(cornerRadius: 16)
              .stroke(Color.black, lineWidth: 2)
          )
          .opacity(viewModel.tasks.isEmpty ? 0 : 1.0)
          .animation(.easeInOut(duration: 0.33), value: viewModel.tasks.isEmpty)

        Spacer()

        HStack {
          // Show `Sign out` if user is not anonymous,
          // otherwise show `Sign-in` to present LoginView() when tapped.
          Button {
            loginViewModel.showLoginSheet = true
            if authManager.authState == .signedIn {
              signOut()
            }
          } label: {
            Text(authManager.authState != .signedIn ? "Sign-in" :"Sign out")
              .font(.body.bold())
              .frame(width: 150, height: 45, alignment: .center)
              .foregroundStyle(.mint)
              .background(.blue)
              .cornerRadius(10)
          }

          // Delete Account
          Button {
            showDeleteAccountAlert = true
          } label: {
            Text("Delete Account")
              .font(.body.bold())
              .frame(width: 150, height: 45, alignment: .center)
              .foregroundStyle(.red)
              .background(.blue)
              .cornerRadius(10)
          }
        }
      }
      .padding()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.mint)
      .navigationTitle("Welcome")

      .sheet(isPresented: $loginViewModel.showLoginSheet) {
        LoginView(viewModel: loginViewModel)
      }
      .confirmationDialog("Delete Account", isPresented: $showDeleteAccountAlert) {
        Button("Yes, Delete", role: .destructive) {
          Task {
            do {
              try await authManager.deleteUserAccount()
            }
            catch AuthErrors.ReauthenticateApple {
              // AppleID re-authentication failed
            }
            catch AuthErrors.RevokeAppleID {
              // AppleID token revocation failed
            }
            catch AuthErrors.ReauthenticateGoogle {
              // Google re-authentication failed
            }
            catch AuthErrors.RevokeGoogle {
              // Google token revocation failed
            }
            catch {
              // Show generic error message
            }
          }
        }
      } message: {
        Text("Deleting account is permanent. Are you sure you want to delete your account?")
      }
    }
  }

  func signOut() {
    Task {
      do {
        try await authManager.signOut()
        loginViewModel.signOut()
      }
      catch {
        print("Error: \(error)")
      }
    }
  }
}

#Preview {
  HomeView()
    .environmentObject(AuthManager())
}
