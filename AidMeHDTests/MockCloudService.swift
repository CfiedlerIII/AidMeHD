//
//  MockCloudService.swift
//  AidMeHDTests
//
//  Created by Charles Fiedler on 3/12/26.
//

import Combine
import Foundation

struct MockJsonObject: Codable {
  var household: AidMeHousehold
  var tasks: [AidMeTask]
}

actor MockCloudService: ObservableObject, @preconcurrency AidMeDataService {
  @Published var user: AidMeUser?
  @Published var household: AidMeHousehold?
  @Published var tasks: [AidMeTask] = []
  static var shared: MockCloudService = MockCloudService()

  var userPublisher: Published<AidMeUser?>.Publisher { $user }
  var householdPublisher: Published<AidMeHousehold?>.Publisher { $household }
  var taskPublisher: Published<[AidMeTask]>.Publisher { $tasks }

  private init() {
    Task { @MainActor in
      await fetchData()
    }
  }

  func fetchData() {
    let myBundle = Bundle(for: MockCloudService.self)
    // Fetch User
    guard let url = myBundle.url(forResource: "mockUser", withExtension: "json") else {
      print("Failed to locate mockUser.json data source")
      return
    }
    guard let data = try? Data(contentsOf: url),
          let decodedUser = try? JSONDecoder().decode(AidMeUser.self, from: data) else {
      print("Failed to decode mockUser.json")
      return
    }
    self.user = decodedUser

    // Fetch Household
    guard let url = myBundle.url(forResource: "mockHousehold", withExtension: "json") else {
      print("Failed to locate mockHousehold.json data source")
      return
    }
    guard let data = try? Data(contentsOf: url),
          let decodedObject = try? JSONDecoder().decode(MockJsonObject.self, from: data) else {
      print("Failed to decode mockHousehold.json")
      return
    }
    self.household = decodedObject.household
    self.tasks = decodedObject.tasks
  }
}
