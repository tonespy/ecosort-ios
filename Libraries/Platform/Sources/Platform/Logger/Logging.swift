//
//  Logging.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation
import OSLog

public protocol Logging {
  func log(message: String)
}

public struct AppLogger: Logging {
  public init() {}
  
  private var isLoggingEnabled: Bool {
    #if DEBUG
      return true
    #else
      return false
    #endif
  }
  
  public func log(message: String) {
    guard isLoggingEnabled else { return }
    Logger.statistics.info("\(message)")
  }
}

public extension Logger {
  /// Using your bundle identifier is a great way to ensure a unique identifier.
  private static var subsystem = Bundle.main.bundleIdentifier!
  
  /// Logs the view cycles like a view that appeared.
  static let viewCycle = Logger(subsystem: subsystem, category: "viewcycle")
  
  /// All logs related to tracking and analytics.
  static let statistics = Logger(subsystem: subsystem, category: "statistics")
}
