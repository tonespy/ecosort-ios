//
//  File.swift
//  Platform
//
//  Created by Abubakar Oladeji on 06/02/2025.
//

import Foundation

public struct PredictionConfig: RequestModelConforms {
  public let versions: [PredictVersionModelVersion]
  public let classes: [PredictionClasses]
  public let groups: [ClassGroupConfig]

  public static func == (lhs: PredictionConfig, rhs: PredictionConfig) -> Bool {
    return lhs.versions == rhs.versions && lhs.classes == rhs.classes && lhs.groups == rhs.groups
  }

  enum CodingKeys: String, CodingKey {
    case versions
    case classes
    case groups
  }
}

public struct PredictVersionModelVersion: RequestModelConforms {
  public let version: String
  public let date: String
  public let url: String
  public let size: String
  public let tfliteModelUrl: String
  public let tfliteModelSize: String
  public let accuracy: String

  public static func == (lhs: PredictVersionModelVersion, rhs: PredictVersionModelVersion) -> Bool {
    return lhs.version == rhs.version && lhs.date == rhs.date && lhs.tfliteModelUrl == rhs.tfliteModelUrl
  }

  enum CodingKeys: String, CodingKey {
    case version
    case date
    case url
    case size = "model_size"
    case tfliteModelUrl = "tflite_url"
    case tfliteModelSize = "tflite_size"
    case accuracy
  }

  public var isSaved: Bool {
    guard let path = try? FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    ).appendingPathComponent("tflite_models", isDirectory: true) else {
      return false
    }
    let fullPath = path
      .appendingPathComponent("v\(version)")
      .appendingPathExtension("tflite")

    return FileManager.default.fileExists(atPath: fullPath.path)
  }

  public var isDefault: Bool {
    let findModel = UserDefaults.standard.userPreference?.savedModels
      .first { $0.model.version == version }
    return findModel?.isDefault ?? false
  }
}

public struct PredictionClasses: RequestModelConforms {
  public let index: Int
  public let name: String
  public let readableName: String
  public let description: String

  public static func == (lhs: PredictionClasses, rhs: PredictionClasses) -> Bool {
    return lhs.index == rhs.index && lhs.name == rhs.name && lhs.readableName == rhs.readableName && lhs.description == rhs.description
  }

  enum CodingKeys: String, CodingKey {
    case index
    case name
    case readableName = "readable_name"
    case description
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(index)
    hasher.combine(name)
    hasher.combine(readableName)
    hasher.combine(description)
  }
}
