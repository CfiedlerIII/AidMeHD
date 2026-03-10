//
//  AidMeHDApp.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/5/26.
//

import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct AidMeHDApp: App {
  @StateObject var authManager: AuthManager

  init() {
    FirebaseApp.configure()
    if let clientID = FirebaseApp.app()?.options.clientID {
      let config = GIDConfiguration(clientID: clientID)
      GIDSignIn.sharedInstance.configuration = config
    }
    let authManager = AuthManager()
    _authManager = StateObject(wrappedValue: authManager)
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(authManager)
        .onOpenURL { url in
          //Handle Google Oauth URL
          GIDSignIn.sharedInstance.handle(url)
        }
    }
  }
}
