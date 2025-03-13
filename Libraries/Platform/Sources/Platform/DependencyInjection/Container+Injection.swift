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
    #if DEBUG
    return URL(string: "http://localhost:5500")!
    #else
    return URL(string: "to be discussed")!
    #endif
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
