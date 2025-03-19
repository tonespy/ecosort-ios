//
//  UserDefaults+Extension.swift
//  Platform
//
//  Created by Abubakar Oladeji on 13/03/2025.
//

import Foundation

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
