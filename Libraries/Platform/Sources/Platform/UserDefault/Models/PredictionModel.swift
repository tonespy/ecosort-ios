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

public struct UserPreferences: Codable, Sendable {
  public var userOnboarded: Bool
  public var preferredPredictionType: PredictionType
  public var savedModels: [SavedModel]
  public var allModels: [PredictVersionModelVersion]

  public init(
    userOnboarded: Bool,
    preferredPredictionType: PredictionType,
    models: [SavedModel] = [],
    allModels: [PredictVersionModelVersion] = []
  ) {
    self.userOnboarded = userOnboarded
    self.preferredPredictionType = preferredPredictionType
    self.savedModels = models
    self.allModels = allModels
  }
}

public struct SavedModel: Codable, Sendable {
  public var model: PredictVersionModelVersion
  public var isDefault: Bool

  public init(model: PredictVersionModelVersion, isDefault: Bool) {
    self.model = model
    self.isDefault = isDefault
  }
}

public extension UserDefaults {
  static var userPreferenceKey: String = "Ecosort_User_Preferred_Prediction_Type"
  static let userOnboardingKey = "Ecosort_Onboarding_hasOnboarded"
  static let applicationCofiguration = "Ecosort_Application_Configuration"

  var onboardingStatus: Bool {
    get {
      bool(forKey: UserDefaults.userOnboardingKey)
    }
    set {
      set(newValue, forKey: UserDefaults.userOnboardingKey)
    }
  }
  
  var userPreference: UserPreferences? {
    get {
      guard let data = data(forKey: UserDefaults.userPreferenceKey) else { return nil }
      return try? JSONDecoder().decode(UserPreferences.self, from: data)
    }
    set {
      if let newValue, let encoded = try? JSONEncoder().encode(newValue) {
        self.onboardingStatus = newValue.userOnboarded
        set(encoded, forKey: UserDefaults.userPreferenceKey)
      }
    }
  }

  var predictionConfiguration: PredictionConfig? {
    get {
      guard let config = data(forKey: UserDefaults.applicationCofiguration) else { return nil }
      return try? JSONDecoder().decode(PredictionConfig.self, from: config)
    }
    set {
      if let newValue, let encoded = try? JSONEncoder().encode(newValue) {
        set(encoded, forKey: UserDefaults.applicationCofiguration)
      }
    }
  }
}
