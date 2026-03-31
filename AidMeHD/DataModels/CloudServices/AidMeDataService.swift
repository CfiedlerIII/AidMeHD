//
//  AidMeDataService.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/12/26.
//

import Foundation

protocol AidMeDataService {
  var user: AidMeUser? { get set }
  var household: AidMeHousehold? { get set }
  var tasks: [AidMeTask] { get set }
  static var shared: Self { get }
  // The protocol requires a publisher
  var userPublisher: Published<AidMeUser?>.Publisher { get }
  var householdPublisher: Published<AidMeHousehold?>.Publisher { get }
  var taskPublisher: Published<[AidMeTask]>.Publisher { get }

  func setNewUser(userId: String, completion: @escaping (Result<AidMeUser,Error>) -> Void)
  func signInUser(userId: String)
  func signOutUser()
}
