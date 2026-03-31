//
//  UserSearchView.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/24/26.
//

import SwiftUI

@MainActor
class UserSearchViewModel: ObservableObject {
  let cloudService = CloudService.shared
  @Published var searchText: String = ""
  @Published var filteredUsers: [AidMeUser] = []

  init(searchText: String = "", filteredUsers: [AidMeUser] = []) {
    self.searchText = searchText
    self.filteredUsers = filteredUsers
    Task {
      self.filteredUsers = await cloudService.allUsers
    }
  }
}

struct UserSearchView: View {
  @AppStorage("userId") var userId: String?
  @ObservedObject var viewModel: UserSearchViewModel = .init()
  @State var searchText: String = ""

  var body: some View {
    ScrollView {
      TextField("Search for user", text: $searchText)
        .padding()
      ForEach(viewModel.filteredUsers) { user in
        Text("\(user.firstName ?? "") \(user.lastName ?? "")")
      }
    }
  }
}

#Preview {
  UserSearchView()
}
