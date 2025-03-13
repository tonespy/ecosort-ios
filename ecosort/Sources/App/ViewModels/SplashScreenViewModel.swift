//
//  SplashScreenViewModel.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 08/02/2025.
//

import SwiftUI
import Combine
import Factory
import Platform

class SplashScreenViewModel: ObservableObject {
  @Injected(\.downloadManager) private var downloadManager: DownloadManager
  @Injected(\.predictionService) private var predictionService: PredictionAPIService
  
  @Published var isLoading: Bool = false
  @Binding var state: AppState
  
  init(state: Binding<AppState>) {
    _state = state
  }
  
  func loadVersions() {
    Task { @MainActor in
      do {
        isLoading = true
        let appConfig = try await predictionService.getAppConfig()

        try await Task.sleep(nanoseconds: 2_000_000_000)

        UserDefaults.standard.predictionConfiguration = appConfig
        downloadManager.updateModelVersions(versions: appConfig.versions)
        moveOn()
      } catch {
        moveOn()
      }
    }
  }

  private func moveOn() {
    isLoading = false
    changeViewState()
  }

  private func changeViewState() {
    guard let pref = UserDefaults.standard.userPreference, pref.userOnboarded else {
      state = .onboarding
      return
    }
    state = .app
  }
}
