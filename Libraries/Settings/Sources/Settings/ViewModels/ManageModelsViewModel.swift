//
//  ManageModelsViewModel.swift
//  Settings
//
//  Created by Abubakar Oladeji on 04/03/2025.
//

import Combine
import Foundation
import Platform

enum ModelDownloadState: Sendable, Equatable {
  case notdownloaded
  case cancelled
  case downloaded
  case failed
  case queued
  case downloading(Double)
}

struct ModelInformation: Sendable, Identifiable, Equatable {
  let id = UUID()
  let model: PredictVersionModelVersion
  let downloadState: ModelDownloadState
  let isDefault: Bool
  let additionalMessage: String?

  init(
    model: PredictVersionModelVersion,
    downloadState: ModelDownloadState,
    isDefault: Bool,
    additionalMessage: String? = nil
  ) {
    self.model = model
    self.downloadState = downloadState
    self.isDefault = isDefault
    self.additionalMessage = additionalMessage
  }

  var defaultMessage: String {
    if isDefault {
      return "Default"
    }
    return "Set as Default"
  }
}

struct DownloadTracking {
  let version: String
  var state: ModelDownloadState
}

class ManageModelsViewModel: NSObject, ObservableObject {
  private let downloadManager: DownloadManager
  private let predictionService: PredictionAPIService

  private var downloadTrackings: [DownloadTracking] = []

  @Published var predictionTypes: [PredictionModel] = [
    .init(type: .cloudAI),
    .init(type: .onDeviceAI),
  ]
  @Published var selectedPredictionType: PredictionType?
  @Published var canUserSave = false
  @Published var models: [ModelInformation] = []

  private var subscriptions = Set<AnyCancellable>()

  init (downloadManager: DownloadManager, predictionService: PredictionAPIService) {
    self.downloadManager = downloadManager
    self.predictionService = predictionService
    super.init()

    observe()
  }

  private func observe() {
    selectedPredictionType = UserDefaults.standard.userPreference?.preferredPredictionType
    downloadManager.failureHandler = { [weak self] (url, error, version) in
      guard let self else { return }
      let index = self.downloadTrackings.firstIndex { current in
        current.version == version
      }
      guard let index else { return }
      self.downloadTrackings[index].state = .failed
      self.reloadListItems()
    }

    downloadManager.completionHandler = {
      [weak self] (_, version, isSaved) in
      guard let self else { return }
      let index = self.downloadTrackings.firstIndex { current in
        current.version == version
      }
      guard let index else { return }
      self.downloadTrackings[index].state = isSaved ? .downloaded : .failed
      self.reloadListItems()
    }

    downloadManager.$currentQueItemWithProgress
      .dropFirst()
      .sink { [weak self] result in
        guard let self, let result else { return }
        let (version, _, progress) = result
        let index = self.downloadTrackings.firstIndex { current in
          current.version == version
        }
        guard let index else { return }
        self.downloadTrackings[index].state = .downloading(progress)
        self.reloadListItems()
      }
      .store(in: &subscriptions)

    modifySelection()
  }

  private func modifySelection() {
    self.predictionTypes = predictionTypes.map({ current in
      PredictionModel(
        type: current.type,
        selected: current.type == selectedPredictionType
      )
    })
    reloadListItems()
  }

  private func reloadListItems() {
    guard
      let selectedPredictionType, selectedPredictionType == .onDeviceAI,
      let availableModels = UserDefaults.standard.userPreference?.allModels else {
      models = []
      return
    }

    let models = availableModels.map { version in
      let downloadState: ModelDownloadState
      if version.isSaved {
        downloadState = .downloaded
      } else {
        let firstState = self.downloadTrackings.first(
          where: { $0.version == version.version
          })?.state
        if let firstState = firstState {
          downloadState = firstState
        } else {
          downloadState = .notdownloaded
        }
      }

      return ModelInformation(
        model: version,
        downloadState: downloadState,
        isDefault: version.isDefault,
        additionalMessage: downloadState == ModelDownloadState.failed ? "Download failed!!!" : nil
      )
    }
    self.models = models
  }

  func updateSelectedPredictionType(_ predictionType: PredictionType) {
    guard selectedPredictionType != predictionType else {
      return
    }

    self.selectedPredictionType = predictionType
    modifySelection()
    checkIfSaveIsNeeded()
  }

  private func checkIfSaveIsNeeded() {
    guard let preference = UserDefaults.standard.userPreference else {
      return
    }

    let isPredictionChanged = preference.preferredPredictionType != selectedPredictionType

    let savedModels = UserDefaults.standard.userPreference?.savedModels ?? []

    if preference.preferredPredictionType == .cloudAI && selectedPredictionType == .onDeviceAI {
      canUserSave = !savedModels.isEmpty && savedModels.first {
        $0.isDefault
      } != nil
      return
    }

    canUserSave = isPredictionChanged
  }

  func saveModelConfiguration() {
    guard var preference = UserDefaults.standard.userPreference, let selectedPredictionType else {
      return
    }
    preference.preferredPredictionType = selectedPredictionType
    UserDefaults.standard.userPreference = preference
  }

  @MainActor
  func loadConfig() async {
    do {
      let service = predictionService
      let appConfig = try await Task
        .detached(
          priority: .userInitiated
        ) {
          try await service.getAppConfig()
        }.value
      downloadManager.updateModelVersions(versions: appConfig.versions)
      UserDefaults.standard.predictionConfiguration = appConfig
      reloadListItems()
    } catch {
      print("Error: ", error)
    }
  }

  func downloadModel(_ model: ModelInformation) {
    guard let url = URL(string: model.model.tfliteModelUrl), !models.isEmpty else {
      return
    }
    let recentVersion = models.sorted {
      $0.model.version > $1.model.version
    }.first!.model.version
    let hasDefaultModel = UserDefaults.standard.userPreference?.savedModels.first {
      $0.isDefault
    }.map { $0.isDefault } ?? false

    if !hasDefaultModel && model.model.version == recentVersion {
      var savedModels = UserDefaults.standard.userPreference?.savedModels ?? []
      if savedModels.isEmpty {
        savedModels = [
          SavedModel(model: model.model, isDefault: true)
        ]
      } else {
        for var savedModel in savedModels { savedModel.isDefault = false }
        savedModels.append(SavedModel(model: model.model, isDefault: true))
        UserDefaults.standard.userPreference?.savedModels = savedModels
      }
    }

    downloadTrackings
      .append(
        DownloadTracking(
          version: model.model.version,
          state: .queued
        )
      )
    downloadManager
      .startDownload(
        from: url,
        version: model.model.version
      )
    reloadListItems()
  }

  func cancelModelDownload(_ model: ModelInformation) {
    downloadTrackings.removeAll { item in
      item.version == model.model.version
    }
    downloadManager.cancelCurrentDownload(version: model.model.version)
    reloadListItems()
  }

  private func getDocumentsDirectory() throws -> URL {
    // Get the documents directory url
    let path = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    ).appendingPathComponent("tflite_models", isDirectory: true)

    return path
  }

  func deleteModel(_ model: ModelInformation) {
    guard var userPrefs = UserDefaults.standard.userPreference else { return }
    var models = userPrefs.savedModels
    downloadTrackings.removeAll { item in
      item.version == model.model.version
    }

    models.removeAll { $0.model.version == model.model.version }
    userPrefs.savedModels = models
    UserDefaults.standard.userPreference = userPrefs

    do {
      let fileUrl = try getDocumentsDirectory()
        .appendingPathComponent("v\(model.model.version)")
        .appendingPathExtension("tflite")

      try FileManager.default.removeItem(at: fileUrl)
      print("Successfully deleted model")
    } catch {
      print("Failed to delete model")
    }
    reloadListItems()
  }

  func setDefaultModel(_ model: ModelInformation) {
    guard var userPrefs = UserDefaults.standard.userPreference else { return }
    var models = userPrefs.savedModels
    let isModelPresent = models.contains(where: { $0.model.version == model.model.version })

    if models.isEmpty || !isModelPresent {
      let isDefault = model.isDefault ? false : true
      models = models.map { SavedModel(model: $0.model, isDefault: false) }
      models.append(SavedModel(model: model.model, isDefault: isDefault))
    } else {
      models = models.map({ currentModel in
        var newModel = SavedModel(model: currentModel.model, isDefault: false)
        if model.model.version == currentModel.model.version {
          newModel.isDefault = !currentModel.isDefault
          return newModel
        }
        return newModel
      })
    }

    print(models)
    userPrefs.savedModels = models
    UserDefaults.standard.userPreference = userPrefs

    if !model.model.isSaved {
      downloadModel(model)
      checkIfSaveIsNeeded()
      return
    }

    checkIfSaveIsNeeded()
    reloadListItems()
  }
}
