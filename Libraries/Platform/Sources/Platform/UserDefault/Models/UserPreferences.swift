//
//  UserPreferences.swift
//  Platform
//
//  Created by Abubakar Oladeji on 13/03/2025.
//

public struct UserConfigedGroups: Codable, Sendable {
  public let config: ClassGroupConfig
  public let isDefault: Bool

  public init(config: ClassGroupConfig, isDefault: Bool) {
    self.config = config
    self.isDefault = isDefault
  }
}

public struct UserPreferences: Codable, Sendable {
  public var userOnboarded: Bool
  public var preferredPredictionType: PredictionType
  public var savedModels: [SavedModel]
  public var allModels: [PredictVersionModelVersion]
  public var savedGroups: [UserConfigedGroups]

  public init(
    userOnboarded: Bool,
    preferredPredictionType: PredictionType,
    models: [SavedModel] = [],
    allModels: [PredictVersionModelVersion] = [],
    savedGroups: [UserConfigedGroups] = []
  ) {
    self.userOnboarded = userOnboarded
    self.preferredPredictionType = preferredPredictionType
    self.savedModels = models
    self.allModels = allModels
    self.savedGroups = savedGroups
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
