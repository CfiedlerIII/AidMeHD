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
