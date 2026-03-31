//
//  AccountSetupView.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/28/26.
//

import SwiftUI

struct AccountSetupView: View {
  @AppStorage("userId") var userId: String?
  @State private var firstName: String = ""
  @State private var lastName: String = ""
  @Binding var showLoginSheet: Bool
  private var cloudService = CloudService.shared
  private let elementBackgroundColor = Color(UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0))

  init(showLoginSheet: Binding<Bool>) {
    self._showLoginSheet = showLoginSheet
  }

  var body: some View {
    VStack(alignment: .center) {
      Text("New Account Info")
        .font(.headline)
        .padding(.bottom)
      TextField("First Name", text: $firstName)
        .padding(8)
        .background(elementBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(.gray, lineWidth: 1)
        )
      TextField("Last Name", text: $lastName)
        .padding(8)
        .background(elementBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(.gray, lineWidth: 1)
        )
      Spacer()
      Button {
        updateUserWithNewInfo()
      } label: {
        Text("Update Account")
          .padding()
          .background(elementBackgroundColor)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(.gray, lineWidth: 1)
          )
      }
      .disabled(firstName.isEmpty || lastName.isEmpty)
    }
    .padding()
    .background(.mint)
  }

  private func updateUserWithNewInfo() {
    Task {
      guard var updatedUser = await cloudService.user else {
        print("Failed to get user")
        return
      }
      updatedUser.firstName = self.firstName
      updatedUser.lastName = self.lastName
      updatedUser.isSetupComplete = true
      await cloudService.updateUser(updatedUser: updatedUser)
      showLoginSheet = false
    }
  }
}

#Preview {
  AccountSetupView(showLoginSheet: .constant(true))
}
