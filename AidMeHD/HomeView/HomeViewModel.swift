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
  @AppStorage("userId") var userId: String?
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

  func fetchHousehold() {
    guard let userId = userId else {
      print("No valid userId found for query")
      return
    }
    print("userId: \(userId)")
    let db = Firestore.firestore()
    db.collection("households")
      .whereField("memberIds", arrayContains: userId)
      .getDocuments { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
          print("No documents: \(error?.localizedDescription ?? "Unknown error")")
          return
        }
        guard let matchingHousehold = documents.first else {
          self.tasks = []
          return
        }
        self.fetchTasksForHousehold(matchingHousehold)
      }
  }

  func fetchTasksForHousehold(_ household: QueryDocumentSnapshot) {
    listenerRegistration = household.reference.collection("tasks")
      .addSnapshotListener { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
          print("No documents: \(error?.localizedDescription ?? "Unknown error")")
          return
        }

        // Automatically decodes documents into an array of Household objects
        let householdTasks: [AidMeTask] = documents.compactMap { document in
          do {
            return try document.data(as: AidMeTask.self)
          } catch {
            print("Error decoding document: \(error)")
            return nil
          }
        }
        print("Tasks: \(householdTasks)")
        self.tasks = householdTasks
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

struct Household: Codable, Identifiable {
  var id: String
  var memberIds: [String]
  var tasks: [AidMeTask]
}
