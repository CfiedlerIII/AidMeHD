//
//  AidMeModelTests.swift
//  AidMeHDTests
//
//  Created by Charles Fiedler on 3/12/26.
//

import Foundation
import Testing

// A helper class to get a reference to the test bundle
private class BundleLocator { }

struct AidMeModelTests {
  let decoder: JSONDecoder = JSONDecoder()

  @Test func testHappyTaskDecoding() async throws {
    // SETUP
    let validDataStringToTest = """
      {"id": "kjsdf8765f78g4fwe","title": "Task Title", "description": "There's nothing to see here. Just a task description.", "isComplete": false}
    """
    // ACTION
    let taskToTest = try? decoder.decode(AidMeTask.self, from: validDataStringToTest.data(using: .utf8)!)
    // VALIDATION
    #expect(taskToTest?.id == "kjsdf8765f78g4fwe")
    #expect(await taskToTest?.title == "Task Title")
    #expect(await taskToTest?.description == "There's nothing to see here. Just a task description.")
    #expect(await taskToTest?.isComplete == false)
  }

  @Test func testInvalidTaskIdDecoding1() async throws {
    let invalidDataStringToTest = """
      {"id": 24601,"title": "Task Title", "description": "There's nothing to see here. Just a task description.", "isComplete": false}
    """
    // ACTION
    let taskToTest = try? decoder.decode(AidMeTask.self, from: invalidDataStringToTest.data(using: .utf8)!)
    // VALIDATION
    #expect(taskToTest == nil)
  }

  @Test func testInvalidTaskIdDecoding2() async throws {
    let invalidDataStringToTest = """
      {"id": null, "title": "Task Title", "description": "There's nothing to see here. Just a task description.", "isComplete": false}
    """
    // ACTION
    let taskToTest = try? decoder.decode(AidMeTask.self, from: invalidDataStringToTest.data(using: .utf8)!)
    // VALIDATION
    #expect(taskToTest == nil)
  }

  @Test func testInvalidTaskTitleDecoding1() async throws {
    let invalidDataStringToTest = """
      {"id": "kjsdf8765f78g4fwe","title": null, "description": "There's nothing to see here. Just a task description.", "isComplete": false}
    """
    // ACTION
    let taskToTest = try? decoder.decode(AidMeTask.self, from: invalidDataStringToTest.data(using: .utf8)!)
    // VALIDATION
    #expect(taskToTest == nil)
  }

  @Test func testInvalidTaskTitleDecoding2() async throws {
    let invalidDataStringToTest = """
      {"id": "kjsdf8765f78g4fwe","title": 42, "description": "There's nothing to see here. Just a task description.", "isComplete": false}
    """
    // ACTION
    let taskToTest = try? decoder.decode(AidMeTask.self, from: invalidDataStringToTest.data(using: .utf8)!)
    // VALIDATION
    #expect(taskToTest == nil)
  }

  @Test func testInvalidTaskCompleteDecoding1() async throws {
    let invalidDataStringToTest = """
      {"id": "kjsdf8765f78g4fwe","title": "Task Title", "description": "There's nothing to see here. Just a task description.", "isComplete": null}
    """
    // ACTION
    let taskToTest = try? decoder.decode(AidMeTask.self, from: invalidDataStringToTest.data(using: .utf8)!)
    // VALIDATION
    #expect(taskToTest == nil)
  }

  @Test func testInvalidTaskCompleteDecoding2() async throws {
    let invalidDataStringToTest = """
      {"id": "kjsdf8765f78g4fwe","title": "Task Title", "description": "There's nothing to see here. Just a task description.", "isComplete": "seven7"}
    """
    // ACTION
    let taskToTest = try? decoder.decode(AidMeTask.self, from: invalidDataStringToTest.data(using: .utf8)!)
    // VALIDATION
    #expect(taskToTest == nil)
  }

  @Test func testHouseholdModelDecoding() async throws {
    // SETUP
    let testBundle = Bundle(for: BundleLocator.self)
    guard let url = testBundle.url(forResource: "mockHousehold", withExtension: "json") else {
      throw MKError.runtimeError("File not found")
    }
    guard let data = try? Data(contentsOf: url) else {
      throw MKError.runtimeError("Failed to convert file to Data")
    }
    // ACTION
    guard let decodedObject = try? decoder.decode(MockJsonObject.self, from: data) else {
      throw MKError.runtimeError("Failed to decode JSON into Household")
    }
    // VALIDATION
    #expect(decodedObject.household.id == "8e5aHNpCCbs1ShtHMYGc")
    #expect(await decodedObject.household.memberIds.count == 1)
    #expect(await decodedObject.household.memberIds.first == "0MFHz5Djh7grgTEhZMlVyFjZTRH2")
    #expect(await decodedObject.tasks.count == 3)
  }

  @Test func testMockCloudServiceDecoding() async throws {
    // SETUP & ACTION
    let mockService = MockCloudService.shared
    // VALIDATION
    _ = await mockService.$user.sink { user in
      Task {
        if user != nil {
          #expect(await user!.id == "0MFHz5Djh7grgTEhZMlVyFjZTRH2")
          #expect(await user!.householdId == "8e5aHNpCCbs1ShtHMYGc")
        }
      }
    }
    _ = await mockService.$household.sink { household in
      Task {
        #expect(await household?.id == "8e5aHNpCCbs1ShtHMYGc")
        #expect(await household?.memberIds.count == 1)
        #expect(await household?.memberIds.first == "0MFHz5Djh7grgTEhZMlVyFjZTRH2")
      }
    }
    _ = await mockService.$tasks.sink { tasks in
      Task {
        #expect(await mockService.tasks.count == 3)
      }
    }
  }
}
