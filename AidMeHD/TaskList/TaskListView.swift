//
//  TaskListView.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/11/26.
//

import SwiftUI

struct TaskListView: View {
  @ObservedObject var viewModel: TasksViewModel<CloudService>

  init(viewModel: TasksViewModel<CloudService>) {
    self.viewModel = viewModel
  }

  var body: some View {
    List {
      ForEach(viewModel.tasks) { task in
        TaskItemView(task: task)
        .listRowSeparator(.hidden)
      }
    }
    .listStyle(.plain)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

#Preview {
  TaskListView(viewModel: .init(dataService: CloudService.shared))
}
