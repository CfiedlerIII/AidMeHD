//
//  AidMeUser.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import FirebaseFirestore
import Foundation

struct AidMeUser: Codable, Identifiable, Equatable {
  let id: String
  var householdId: String?
  var firstName: String?
  var lastName: String?
  var isSetupComplete: Bool

  init(id: String, householdId: String?, firstName: String? = nil, lastName: String? = nil, isSetupComplete: Bool = false) {
    self.id = id
    self.householdId = householdId
    self.firstName = firstName
    self.lastName = lastName
    self.isSetupComplete = isSetupComplete
  }

  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.householdId = try container.decodeIfPresent(String.self, forKey: .householdId)
    self.firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
    self.lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
    self.isSetupComplete = try container.decode(Bool.self, forKey: .isSetupComplete)
  }

  static func == (lhs: AidMeUser, rhs: AidMeUser) -> Bool {
    let cond1 = lhs.id == rhs.id
    let cond2 = lhs.householdId == rhs.householdId
    let cond3 = lhs.firstName == rhs.firstName
    let cond4 = lhs.lastName == rhs.lastName
    let cond5 = lhs.isSetupComplete == rhs.isSetupComplete
    return cond1 && cond2 && cond3 && cond4 && cond5
  }

  static func != (lhs: Self, rhs: Self) -> Bool {
    let cond1 = lhs.id != rhs.id
    let cond2 = lhs.householdId != rhs.householdId
    let cond3 = lhs.firstName != rhs.firstName
    let cond4 = lhs.lastName != rhs.lastName
    let cond5 = lhs.isSetupComplete != rhs.isSetupComplete
    return cond1 || cond2 || cond3 || cond4 || cond5
  }
}
