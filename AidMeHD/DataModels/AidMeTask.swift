//
//  AidMeTask.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import Foundation

actor AidMeTask: @preconcurrency Codable, Identifiable {
  nonisolated let id: String
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
