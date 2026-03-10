//
//  RootView.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/5/26.
//

import SwiftUI

struct RootView: View {
  @EnvironmentObject var authManager: AuthManager

  var body: some View {
    VStack(spacing: 16) {
      if authManager.authState != .signedOut {
        HomeView()
      } else {
        LoginView()
      }
    }
  }
}

#Preview {
  RootView()
}
