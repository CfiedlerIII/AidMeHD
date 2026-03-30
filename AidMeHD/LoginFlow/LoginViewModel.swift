//
//  LoginViewModel.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/29/26.
//

import Combine
import SwiftUI
import FirebaseAuth

@MainActor
class LoginViewModel<DataService>: ObservableObject where DataService: AidMeDataService, DataService: ObservableObject {
  @AppStorage("userId") var userId: String?
  @ObservedObject var dataService: DataService
  @Published var path = NavigationPath()
  @Published var user: AidMeUser?
  @Published var showLoginSheet: Bool = false
  private var cancellables: Set<AnyCancellable> = []

  init(dataService: DataService) {
    self.dataService = dataService
    dataService.userPublisher
      .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
      .sink { [weak self] updatedUser in
        if updatedUser == nil {
          self?.showLoginSheet = true
        } else {
          if updatedUser != self?.user {
            print("User updated.")
            self?.user = updatedUser
            if !(updatedUser?.isSetupComplete ?? true) {
              self?.showLoginSheet = true
              print("Navigating to AccountSetup")
              self?.path.append("AccountSetup")
            }
          }
        }
      }
      .store(in: &cancellables)
  }

  deinit {
    cancellables.removeAll()
  }

  func signIn(userId: String) {
    dataService.signInUser(userId: userId)
  }

  func signOut() {
    dataService.signOutUser()
    showLoginSheet = true
  }

  func createNewUser(email: String, password: String, completion: @escaping ((Error?) -> Void)) {
    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
      if let error = error as NSError? {
        if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
          print("Error creating user: \(error.localizedDescription)")
          completion(error)
          return
        } else {
          // Handle other errors (e.g., invalid email, weak password, network issues)
          print("Error creating user: \(error.localizedDescription)")
          completion(error)
          return
        }
      }
      print("AuthSuccess: \(authResult!.user.uid)")
      self.dataService.signInUser(userId: authResult!.user.uid)
      // User created successfully
      print("User created: \(authResult?.user.email ?? "")")
      Task {
        self.dataService.setNewUser(userId: authResult!.user.uid) { result in
          switch result {
          case .success(_):
            // Optionally, send a verification email
            authResult?.user.sendEmailVerification { error in
              // Handle verification email error or success
              if let error = error as NSError? {
                print("Error sending email verification: \(error.localizedDescription)")
                completion(error)
              } else {
                print("Email verification successfully sent")
              }
            }
          case .failure(let error):
            print("Error creating new user: \(error.localizedDescription)")
            completion(error)
          }
        }
      }
    }
  }
}
