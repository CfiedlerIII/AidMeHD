//
//  CloudService.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import Combine
import FirebaseFirestore
import SwiftUI

actor CloudService: ObservableObject, @preconcurrency AidMeDataService {
  @AppStorage("userId") var userId: String?
  @Published var user: AidMeUser?
  @Published var household: AidMeHousehold?
  @Published var tasks: [AidMeTask] = []
  @Published var allUsers: [AidMeUser] = []
  public static let shared: CloudService = CloudService()
  let database = Firestore.firestore()

  var userPublisher: Published<AidMeUser?>.Publisher { $user }
  var householdPublisher: Published<AidMeHousehold?>.Publisher { $household }
  var taskPublisher: Published<[AidMeTask]>.Publisher { $tasks }
  var allUsersPublisher: Published<[AidMeUser]>.Publisher { $allUsers }

  // Listeners
  var userListener: ListenerRegistration?
  var householdListener: ListenerRegistration?
  var taskListener: ListenerRegistration?
  var allUsersListener: ListenerRegistration?

  private init() {}

  deinit {
    userListener?.remove()
    householdListener?.remove()
    taskListener?.remove()
    allUsersListener?.remove()
  }

  func fetchData() {
    Task {
      await startUserListener()
      await startAllUsersListener()
    }
  }

  func startUserListener() async {
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
          self.user = try document.data(as: AidMeUser.self)
        } catch {
          print("Error decoding user: \(error)")
          return
        }
      }
  }

  func startAllUsersListener() async {
    self.allUsersListener = database
      .collection("users")
      .addSnapshotListener { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
          print("No users: \(error?.localizedDescription ?? "Unknown error")")
          return
        }

        // Automatically decodes documents into an array of Task objects
        let allUsers: [AidMeUser] = documents.compactMap { document in
          do {
            return try document.data(as: AidMeUser.self)
          } catch {
            print("Error decoding user: \(error)")
            return nil
          }
        }
        Task {
          self.allUsers = allUsers
        }
      }
  }

  func setNewUser(userId: String, completion: @escaping (Result<AidMeUser,Error>) -> Void) {
    let householdId = UUID().uuidString
    let userDocRef = database
      .collection("users")
      .document(userId)
    let householdDocRef = database
      .collection("households")
      .document(householdId)

    let dispatchGroup = DispatchGroup()
    var errors: [Error] = []
    dispatchGroup.enter()
    userDocRef.setData(["id":userId,"householdId":householdId,"isSetupComplete": false]) { error in
      if let error = error {
        print("Error writing document: \(error.localizedDescription)")
        errors.append(error)
        dispatchGroup.leave()
      } else {
        print("User successfully written with ID: \(userId)")
        dispatchGroup.leave()
      }
    }
    dispatchGroup.enter()
    householdDocRef.setData(["id": householdId,"memberIds": [userId]]) { error in
      if let error = error {
        print("Error writing document: \(error.localizedDescription)")
        errors.append(error)
        dispatchGroup.leave()
      } else {
        print("Household successfully written with ID: \(householdId)")
        dispatchGroup.leave()
      }
    }
    dispatchGroup.notify(queue: .main) {
      if !errors.isEmpty {
        completion(.failure(errors.first!))
      } else {
        completion(.success(AidMeUser(id: userId, householdId: householdId, isSetupComplete: false)))
      }
    }
  }

  func signInUser(userId: String) {
    self.userId = userId
    Task {
      await self.startUserListener()
    }
  }

  func signOutUser() {
    userId = nil
    userListener?.remove()
  }

  func updateUser(updatedUser: AidMeUser) {
    let userDocRef = database
      .collection("users")
      .document(updatedUser.id)
    do {
        try userDocRef.setData(from: updatedUser, merge: true)
    } catch {
        print("Error updating document: \(error)")
    }
  }

  func startHouseholdListener() async {
    guard let householdId = user?.householdId else { return }

    self.householdListener = database
      .collection("households")
      .document(householdId)
      .addSnapshotListener { document, error in
        guard let document else {
          print("Error fetching household: \(error ?? NSError())")
          return
        }
        do {
          self.household = try document.data(as: AidMeHousehold.self)
          self.startHouseholdTasksListener(document)
        } catch {
          print("Error decoding household: \(error)")
          return
        }
      }
  }

  func startHouseholdTasksListener(_ household: DocumentSnapshot) {
    taskListener = household.reference.collection("tasks")
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
        Task {
          self.tasks = householdTasks
        }
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

  func editTask(_ task: AidMeTask, inHousehold household: QueryDocumentSnapshot) {
    do {
      _ = try household.reference.collection("tasks").document(task.id).setData(from: task)
      print("Task successfully edited!")
    } catch {
      print("Error editing task: \(error.localizedDescription)")
    }
  }
}
