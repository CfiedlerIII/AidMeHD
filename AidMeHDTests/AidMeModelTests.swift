//
//  AidMeModelTests.swift
//  AidMeHDTests
//
//  Created by Charles Fiedler on 3/12/26.
//

import Foundation
import Testing

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
    #expect(taskToTest?.title == "Task Title")
    #expect(taskToTest?.description == "There's nothing to see here. Just a task description.")
    #expect(taskToTest?.isComplete == false)
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
}
