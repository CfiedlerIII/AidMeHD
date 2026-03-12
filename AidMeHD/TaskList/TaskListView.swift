//
//  TaskListView.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/11/26.
//

import SwiftUI

struct TaskListView: View {
  @ObservedObject var viewModel: HomeViewModel

  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
  }
  var body: some View {
    List {
      ForEach(viewModel.tasks) { task in
        VStack(alignment: .leading) {
          Text(task.title)
          if let description = task.description, !description.isEmpty {
            Divider()
            Text(description)
          }
        }
        .listRowSeparator(.hidden)
        .padding()
        .background(task.isComplete ?  Color.green.opacity(0.33) : Color(UIColor.systemGray4))
        .clipShape(RoundedRectangle(cornerRadius: 8))
      }
    }
    .listStyle(.plain)
    .background(.white)
    .clipShape(RoundedRectangle(cornerRadius: 16))
  }
}

#Preview {
  TaskListView(viewModel: .init())
}
