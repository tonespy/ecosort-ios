//
//  SettingsViewModel.swift
//  Settings
//
//  Created by Abubakar Oladeji on 24/02/2025.
//

import Combine
import Foundation
import Platform
import UIKit

enum SettingsSectionIdentifier: Hashable {
  case models
  case notification

  var title: String {
    switch self {
      case .models:
      return "Models"
    case .notification:
      return "Notifications"
    }
  }
}

enum SettingsItemIdentifier: Hashable {
  case models
  case categories
  case notifications
  case modelDownload(String)

  var title: String {
    switch self {
    case .models:
      return "Manage models"
    case .categories:
      return "Customize categories"
    case .notifications:
      return "Notifications"
    case .modelDownload(_):
      return "Model Download in Progress"
    }
  }

  var subtitle: String {
    switch self {
      case .models:
      return "Switch between on-device AI and cloud predictions, and download new model versions."
    case .categories:
      return "Group related classifications (e.g., different types of glass) under a single name."
    case .notifications:
      return "Enable or disable alerts for background tasks.\nNote: Notifications work only if background processing is enabled."
    case .modelDownload(let subtitle):
      return subtitle
    }
  }

  var allowUserInteraction: Bool {
    switch self {
    case .notifications, .modelDownload(_):
      return false
    default:
      return true
    }
  }
}

struct SettingsSection: Hashable, Identifiable, Equatable {
  let id = UUID()
  let identifier: SettingsSectionIdentifier
  var items: [SettingsItem]

  public static func == (lhs: SettingsSection, rhs: SettingsSection) -> Bool {
    lhs.id == rhs.id && lhs.identifier == rhs.identifier && lhs.items == rhs.items
  }
}

struct SettingsItem: Identifiable, Hashable, Equatable {
  let id = UUID()
  let identifier: SettingsItemIdentifier

  public static func == (lhs: SettingsItem, rhs: SettingsItem) -> Bool {
    lhs.id == rhs.id && lhs.identifier == rhs.identifier
  }
}

public final class SettingsViewModel: ObservableObject {
  private let downloadManager: DownloadManager
  private let predictionService: PredictionAPIService

  private var cancellables: Set<AnyCancellable> = []
  var isBackgroundProcessingEnabled: Bool = false

  @Published var sections: [SettingsSection] = []
  @Published var enableNotification: Bool = false
  var isMainViewVisible = true

  var manageModelViewModel: ManageModelsViewModel {
    return ManageModelsViewModel(
      downloadManager: downloadManager,
      predictionService: predictionService
    )
  }

  var manageCategoriesViewModel: ManageCategoriesViewModel {
    return ManageCategoriesViewModel()
  }

  public init(downloadManager: DownloadManager, predictionService: PredictionAPIService) {
    self.downloadManager = downloadManager
    self.predictionService = predictionService
    observeDownloads()
  }

  private func observeDownloads() {
    downloadManager.$progress
      .dropFirst()
      .sink { [weak self] progress in
        guard let self = self, let currentQueueItem = self.downloadManager.currentQueueItem, isMainViewVisible else {
          return
        }

        let (version, _) = currentQueueItem
        self.injectDownloadProgress(version, progress: progress)
      }.store(in: &cancellables)

    $enableNotification
      .dropFirst()
      .sink { status in
        print("Interacted with notification switch: \(status)")
      }.store(in: &cancellables)
  }

  private func injectDownloadProgress(_ version: String, progress: Double) {
    let modelSection = sections.first { $0.identifier == .models }
    let modelSectionIndex = sections.firstIndex { $0.identifier == .models }
    guard !sections.isEmpty, var modelSection, let modelSectionIndex else {
      return
    }

    if progress >= 1 && modelSection.items.count >= 3 {
      modelSection.items.remove(at: 2)
      sections[modelSectionIndex] = modelSection
    } else {
      let readableProgress = "Version \(version) • \(Int(progress * 100)) % complete"
      if modelSection.items.count < 3 {
        modelSection.items.append(SettingsItem(identifier: .modelDownload(readableProgress)))
      } else {
        modelSection.items[2] = SettingsItem(identifier: .modelDownload(readableProgress))
      }
      sections[modelSectionIndex] = modelSection
    }
  }

  private func createModelSection(_ preference: UserPreferences) -> [SettingsSection] {
    let items = [
      SettingsItem(identifier: SettingsItemIdentifier.models),
      SettingsItem(identifier: SettingsItemIdentifier.categories)
    ]

    return [SettingsSection(identifier: .models, items: items)]
  }

  private func createNotificationSection(_ preference: UserPreferences) -> [SettingsSection] {
    if preference.savedModels.isEmpty || preference.preferredPredictionType == .cloudAI {
      return []
    }
    let items = [
      SettingsItem(identifier: SettingsItemIdentifier.notifications)
    ]
    
    return [SettingsSection(identifier: .notification, items: items)]
  }

  func loadSections() {
    guard let userPreferences = UserDefaults.standard.userPreference else {
      return
    }

    sections = createModelSection(userPreferences) + createNotificationSection(userPreferences)
  }
}
