//
//  Container+Injection.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 09/02/2025.
//

import Factory
import Foundation
import Home
import Onboarding
import Platform
import Settings

extension Container {
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
    Factory(self) {
      let loggingMiddleware = APILoggingMiddleware(logger: AppLogger())
      let authMiddleware = APIAuthorizationMiddleware()
      return APIClient(
        baseURL: self.baseURL,
        middleware: [authMiddleware, loggingMiddleware]
      )
    }.singleton
  }
  
  var predictionService: Factory<PredictionAPIService> {
    Factory(self) {
      return PredictionAPIService(apiClient: self.apiClient.resolve())
    }.singleton
  }
  
  var onboarding: Factory<OnboardingViewModel> {
    Factory(self) {
      return OnboardingViewModel(
        downloadManager: Container.shared.downloadManager.resolve(),
        predictionService: Container.shared.predictionService.resolve()
      )
    }.cached
  }
  
  var homwViewModel: Factory<HomeViewModel> {
    Factory(self) {
      return HomeViewModel(
        downloadManager: Container.shared.downloadManager.resolve(),
        predictionService: Container.shared.predictionService.resolve()
      )
    }.cached
  }

  var settingsViewModel: Factory<SettingsViewModel> {
    Factory(self) {
      return SettingsViewModel(
        downloadManager: Container.shared.downloadManager.resolve(),
        predictionService: Container.shared.predictionService.resolve()
      )
    }
  }
}
