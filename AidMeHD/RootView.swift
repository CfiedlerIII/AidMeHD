//
//  RootView.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/5/26.
//

import SwiftUI

struct RootView: View {
  @EnvironmentObject var authManager: AuthManager
  @AppStorage("userId") var userId: String?
  @State private var isLoading = true
  let cloudService = CloudService.shared

  var body: some View {
    ZStack {
      HomeView()
      ProgressView()
        .opacity(isLoading ? 1 : 0)
    }
    .task {
      isLoading = true
      await self.cloudService.fetchData()
      isLoading = false
    }
  }
}

#Preview {
  RootView()
}
