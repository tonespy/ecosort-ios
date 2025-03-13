//
//  OnboardingViewModel.swift
//  Onboarding
//
//  Created by Abubakar Oladeji on 13/01/2025.
//

import Combine
import Factory
import Foundation
import Platform

enum OnboardingPage: Int {
  case information = 0
  case predictionMode = 1
}

public class OnboardingViewModel: ObservableObject {
  private let downloadManager: DownloadManager
  private let predictionService: PredictionAPIService
  
  private var subscriptions = Set<AnyCancellable>()
  
  @Published var flowStage: OnboardingPage = .information
  
  @Published var predictionTypes: [PredictionModel] = [
    .init(type: .cloudAI),
    .init(type: .onDeviceAI),
  ]
  @Published var selectedPredictionType: PredictionType?
  
  @Published var showAlert: Bool = false
  private var userPreferenceInfo: UserPreferences?
  
  var alertMessage: String {
    if let selectedPredictionType, selectedPredictionType == .cloudAI {
      return "Cloud AI is now active. Your predictions will be processed remotely for prompt results."
    }
    guard let latestVersion = downloadManager.modelVersions.first?.version else {
      return "On-Device AI Model is downloading in the background. Cloud AI will handle predictions until the download is complete."
    }
    return "On-Device AI v\(latestVersion) is downloading in the background. Cloud AI will handle predictions until the download is complete."
  }
  
  public init(downloadManager: DownloadManager,
              predictionService: PredictionAPIService) {
    self.downloadManager = downloadManager
    self.predictionService = predictionService
  }
  
  private func modifySelection() {
    self.predictionTypes = predictionTypes.map({ current in
      PredictionModel(
        type: current.type,
        selected: current.type == selectedPredictionType
      )
    })
  }
  
  func updateSelectedPredictionType(_ predictionType: PredictionType) {
    guard selectedPredictionType != predictionType else {
      self.selectedPredictionType = nil
      modifySelection()
      return
    }
    
    self.selectedPredictionType = predictionType
    modifySelection()
  }
  
  func next() {
    if flowStage == .predictionMode {
      if let selectedPredictionType = selectedPredictionType {
        userPreferenceInfo = UserPreferences(
          userOnboarded: true,
          preferredPredictionType: selectedPredictionType
        )

        if !downloadManager.modelVersions.isEmpty {
          userPreferenceInfo?.allModels = downloadManager.modelVersions
        }

        guard selectedPredictionType == .onDeviceAI else {
          showAlert = true
          return
        }

        showAlert = flowStage == .predictionMode
        processUserPreference()
        
        if let latestVersion = downloadManager.modelVersions.first,
           let url = URL(string: latestVersion.tfliteModelUrl) {
          userPreferenceInfo?.savedModels = [SavedModel(model: latestVersion, isDefault: true)]
          downloadManager.startDownload(from: url, version: latestVersion.version)
        }
      }
    } else {
      flowStage = OnboardingPage(rawValue: flowStage.rawValue + 1) ?? .information
    }
  }
  
  func processUserPreference() {
    guard !showAlert, let userPreferenceInfo = userPreferenceInfo else {
      return
    }
    UserDefaults.standard.userPreference = userPreferenceInfo
  }
  
  private func observe() {
    if downloadManager.modelVersions.isEmpty {
      self.predictionTypes = [
        .init(type: .cloudAI),
        .init(type: .onDeviceWithException)
      ]
    }
  }
}

#if DEBUG
extension OnboardingViewModel {
}
#endif
