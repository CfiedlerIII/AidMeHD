//
//  CloudService.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import FirebaseFirestore
import SwiftUI

actor CloudService: ObservableObject {
  @AppStorage("userId") var userId: String?
  @Published var user: DBUser?
  @Published var household: Household?
  @Published var tasks: [AidMeTask] = []
  public static let shared: CloudService = CloudService()
  let database = Firestore.firestore()

  // Listeners
  var userListener: ListenerRegistration?
  var householdListener: ListenerRegistration?
  var tasksListener: ListenerRegistration?

  private init() {
    Task {
      await fetchUser()
    }
  }

  deinit {
    userListener?.remove()
    householdListener?.remove()
    tasksListener?.remove()
  }

  func fetchUser() {
    guard let userId else { return }

    self.userListener = database
      .collection("users")
      .document(userId)
      .addSnapshotListener { document, error in
        guard let document else {
          print("Error fetching user: \(error ?? NSError())")
          return
        }
        do {
          self.user = try document.data(as: DBUser.self)
          self.fetchHousehold()
        } catch {
          print("Error decoding user: \(error)")
          return
        }
      }
  }

  func fetchHousehold() {
    guard let householdId = user?.householdId else { return }
    print("HouseholdID: \(householdId)")

    self.householdListener = database
      .collection("households")
      .document(householdId)
      .addSnapshotListener { document, error in
        guard let document else {
          print("Error fetching household: \(error ?? NSError())")
          return
        }
        do {
          self.household = try document.data(as: Household.self)
          self.fetchTasksForHousehold(document)
        } catch {
          print("Error decoding household: \(error)")
          return
        }
      }
  }

  func fetchTasksForHousehold(_ household: DocumentSnapshot) {
    tasksListener = household.reference.collection("tasks")
      .addSnapshotListener { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
          print("No tasks: \(error?.localizedDescription ?? "Unknown error")")
          return
        }

        // Automatically decodes documents into an array of Task objects
        let householdTasks: [AidMeTask] = documents.compactMap { document in
          do {
            return try document.data(as: AidMeTask.self)
          } catch {
            print("Error decoding tasks: \(error)")
            return nil
          }
        }
        self.tasks = householdTasks
      }
  }

  func addTask(_ newTask: AidMeTask, toHousehold household: QueryDocumentSnapshot) {
    do {
      // Automatically encodes the AidMeTask object into Firestore data
      _ = try household.reference.collection("tasks").addDocument(from: newTask)
      print("Task successfully added!")
    } catch {
      print("Error adding task: \(error.localizedDescription)")
    }
  }
}

struct DBUser: Codable, Identifiable {
  var id: String
  var householdId: String
}
