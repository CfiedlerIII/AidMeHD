//
//  AidMeUser.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import Foundation

actor AidMeUser: @preconcurrency Codable, Identifiable {
  nonisolated let id: String
  var householdId: String
}
