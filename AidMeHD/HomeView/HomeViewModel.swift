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
  @Published var tasks: [AidMeTask] = []
  private var db = Firestore.firestore()
  private var listenerRegistration: ListenerRegistration?

  init(_ tasks: [AidMeTask] = []) {
    self.tasks = tasks
  }

  func fetchTasks() {
    listenerRegistration = db.collection("tasks").addSnapshotListener { (querySnapshot, error) in
      guard let documents = querySnapshot?.documents else {
        print("No documents: \(error?.localizedDescription ?? "Unknown error")")
        return
      }

      // Automatically decodes documents into an array of Book objects
      self.tasks = documents.compactMap { document in
        do {
          return try document.data(as: AidMeTask.self)
        } catch {
          print("Error decoding document: \(error)")
          return nil
        }
      }
    }
  }

  // Remember to remove the listener when it's no longer needed (e.g., in deinit or view disappearance)
  deinit {
    listenerRegistration?.remove()
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
