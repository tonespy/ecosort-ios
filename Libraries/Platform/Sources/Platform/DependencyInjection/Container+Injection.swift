//
//  Container+Injection.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 03/02/2025.
//

import Factory
import Foundation

public extension Container {
  private var baseURL: URL {
    let baseUrl = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String
    let baseUrlProtocol = Bundle.main.object(forInfoDictionaryKey: "BASE_URL_PROTOCOL") as? String
    if let baseUrl = baseUrl, let baseUrlProtocol = baseUrlProtocol {
      return URL(string: "\(baseUrlProtocol)://\(baseUrl)")!
    } else {
      return URL(string: "to be discussed")!
    }
  }
  
  /// A singleton DownloadManager.
  var downloadManager: Factory<DownloadManager> {
    self { DownloadManager() }.singleton
  }
  
  var apiClient: Factory<APIClient> {
    self {
      let loggingMiddleware = APILoggingMiddleware(logger: AppLogger())
      let authMiddleware = APIAuthorizationMiddleware()
      return APIClient(
        baseURL: self.baseURL,
        middleware: [authMiddleware, loggingMiddleware]
      )
    }.singleton
  }
  
  var predictionService: Factory<PredictionAPIService> {
    self {
      return PredictionAPIService(apiClient: self.apiClient.resolve())
    }.singleton
  }
}
