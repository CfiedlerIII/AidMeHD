//
//  Household.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

struct Household: Codable, Identifiable {
  var id: String
  var memberIds: [String]
  var tasks: [AidMeTask]

  // Decodable init
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.id = try container.decode(String.self, forKey: .id)
    self.memberIds = try container.decode([String].self, forKey: .memberIds)
    do {
      tasks = try container.decode([AidMeTask].self, forKey: .tasks)
    } catch {
      print("Failed to decode household tasks: \(error)")
      tasks = []
      return
    }
  }
}
