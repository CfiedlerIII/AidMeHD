//
//  String+.swift
//  AidMeHD
//
//  Created by Charles Fiedler on 3/16/26.
//

import Foundation

extension String {
  func isValidEmail() -> Bool {
    if self.isEmpty {
      return false
    }
    // A common, robust regex for email validation
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: self)
  }
}
