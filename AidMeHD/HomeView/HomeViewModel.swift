//
//  HomeViewModel.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/11/26.
//

import Combine
import FirebaseFirestore
import SwiftUI

class HomeViewModel: ObservableObject {
  @ObservedObject var cloudService = CloudService.shared
  @Published var tasks: [AidMeTask] = []
  private var cancellables: Set<AnyCancellable> = []

  deinit {
    cancellables.removeAll()
  }

  func fetchTasks() {
    cancellables.removeAll()
    Task {
      await cloudService.$tasks
        .debounce(for: 0.15, scheduler: DispatchQueue.main)
        // Assign the output of the publisher to the destination property
        .assign(to: \.tasks, on: self)
        // Store the subscription in the cancellables set
        .store(in: &cancellables)
    }
  }
}

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
