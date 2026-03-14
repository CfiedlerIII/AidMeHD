//
//  TaskItemView.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import SwiftUI

struct TaskItemView: View {
  @State var title: String = ""
  @State var description: String?
  @State var isComplete: Bool = false
  var task: AidMeTask

  var body: some View {
    VStack(alignment: .leading) {
      Text(title)
      if let description = description, !description.isEmpty {
        Divider()
        Text(description)
      }
    }
    .padding()
    .background(isComplete ?  Color.green.opacity(0.33) : Color(UIColor.systemGray4))
    .clipShape(RoundedRectangle(cornerRadius: 8))
    .task {
      // Fetch data from actor
      self.title = await task.title
      self.description = await task.description
      self.isComplete = await task.isComplete
    }
  }
}

#Preview {
  TaskItemView(task: AidMeTask(id: UUID().uuidString, title: "Task Title", isComplete: true))
}
