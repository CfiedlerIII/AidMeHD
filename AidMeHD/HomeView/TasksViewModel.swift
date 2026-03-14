//
//  TasksViewModel.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/11/26.
//

import Combine
import FirebaseFirestore
import SwiftUI

@MainActor
class TasksViewModel<DataService>: ObservableObject where DataService: AidMeDataService, DataService: ObservableObject {
  @ObservedObject var dataService: DataService
  @Published var tasks: [AidMeTask] = []
  private var cancellables: Set<AnyCancellable> = []

  init(dataService: DataService) {
    self.dataService = dataService
    dataService.taskPublisher
      .receive(on: RunLoop.main)
      .sink { [weak self] updatedTasks in
        self?.tasks = updatedTasks
      }
      .store(in: &cancellables)
  }

  deinit {
    cancellables.removeAll()
  }
}
