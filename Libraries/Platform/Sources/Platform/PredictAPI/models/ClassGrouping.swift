//
//  ClassGrouping.swift
//  Platform
//
//  Created by Abubakar Oladeji on 13/03/2025.
//

import Foundation
import OSLog

public protocol RequestModelConforms: Codable, DecodableType, Equatable, Sendable, Hashable {
}

public struct ClassGroupConfig: RequestModelConforms {
  public let name: String
  public let groupConfig: [ClassGrouping]

  enum CodingKeys: String, CodingKey {
    case name
    case groupConfig = "group_config"
  }

  public static func == (lhs: ClassGroupConfig, rhs: ClassGroupConfig) -> Bool {
    return lhs.name == rhs.name && lhs.groupConfig == rhs.groupConfig
  }

  public init(name: String, groupConfig: [ClassGrouping]) {
    self.name = name
    self.groupConfig = groupConfig
  }
}

public struct ClassGrouping: RequestModelConforms {
  public let name: String
  public let classes: [PredictionClasses]

  public static func == (lhs: ClassGrouping, rhs: ClassGrouping) -> Bool {
    return lhs.name == rhs.name && lhs.classes == rhs.classes
  }

  public init(name: String, classes: [PredictionClasses]) {
    self.name = name
    self.classes = classes
  }
}

public extension Encodable {
  func printToJSON() {
    do {
      let jsonData = try JSONEncoder().encode(self)
      let json = try JSONSerialization.jsonObject(
        with: jsonData,
        options: .mutableContainers
      )
      let prettyPrintedData = try JSONSerialization.data(
        withJSONObject: json,
        options: .prettyPrinted
      )
      Logger.statistics.info("JSON: \(String(data: prettyPrintedData, encoding: .utf8) ?? "Error converting to JSON string")")
    } catch {
      Logger.statistics.info("Error printing JSON: \(error)")
    }
  }
}
