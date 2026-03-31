//
//  AidMeHousehold.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import Combine
import Foundation

actor AidMeHousehold: @preconcurrency Codable, Identifiable {
  enum CodingKeys: String, CodingKey {
    case id
    case memberIds
  }

  nonisolated let id: String
  var memberIds: [String]

  init(id: String, memberIds: [String]) {
    self.id = id
    self.memberIds = memberIds
  }

  // Decodable init
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.memberIds = try container.decode([String].self, forKey: .memberIds)
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(memberIds, forKey: .memberIds)
  }
}
