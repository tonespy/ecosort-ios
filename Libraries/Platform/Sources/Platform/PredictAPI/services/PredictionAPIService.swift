//
//  PredictionAPIService.swift
//  Platform
//
//  Created by Abubakar Oladeji on 08/02/2025.
//

import Foundation

public enum PredictionAPIError: Error {
  case versionError
  case imageUploadError
  case videoUploadError
}

public class PredictionAPIService: APIService {
  public func getAppConfig() async throws -> PredictionConfig {
    let apiSpec: PredictAPISpec = .config
    let response = try await apiClient.sendRequest(apiSpec)
    guard let data = response as? PredictionConfig else {
      throw PredictionAPIError.versionError
    }
    return data
  }
}

extension PredictionAPIService: @unchecked Sendable {}
