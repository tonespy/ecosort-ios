//
//  PredictionModel.swift
//  Platform
//
//  Created by Abubakar Oladeji on 24/01/2025.
//

import Foundation

public enum PredictionType: String, Codable, Sendable {
  case cloudAI = "Cloud AI"
  case onDeviceAI = "On-Device AI"
  case onDeviceWithException = "On-Device AI With Exception"
  
  public var title: String {
    switch self {
      case .cloudAI:
      return "Cloud AI"
    case .onDeviceAI, .onDeviceWithException:
      return "On-Device AI"
    }
  }
  
  public var description: String {
    switch self {
    case .cloudAI:
      return "Leverage powerful servers for better prediction capabilities."
    case .onDeviceAI, .onDeviceWithException:
      return "Make offline predictions using the latest model, which you can download directly to your device."
    }
  }
  
  public var subDescription: String? {
    switch self {
    case .onDeviceWithException:
      return ""
    default: return nil
    }
  }
}

public struct PredictionModel: Identifiable, Equatable {
  public let id: String = UUID().uuidString
  public let type: PredictionType
  public var selected = false
  
  public init(type: PredictionType, selected: Bool = false) {
    self.type = type
    self.selected = selected
  }
}
