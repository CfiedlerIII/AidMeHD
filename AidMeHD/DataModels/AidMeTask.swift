//
//  AidMeTask.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

struct AidMeTask: Codable, Identifiable {
  var id: String
  var title: String
  var description: String?
  var isComplete: Bool

  init(id: String, title: String, description: String? = nil, isComplete: Bool) {
    self.id = id
    self.title = title
    self.description = description
    self.isComplete = isComplete
  }
}
