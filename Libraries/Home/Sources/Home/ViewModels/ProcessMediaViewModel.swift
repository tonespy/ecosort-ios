//
//  ProcessMediaViewModel.swift
//  Home
//
//  Created by Abubakar Oladeji on 22/03/2025.
//

import Assets
import Combine
import Foundation
import Platform

enum MediaProcessingState {
  case idle
  case processing
  case completed
  case failed
}

struct ProcessMediaPicker: Identifiable, Hashable {
  let id: String = UUID().uuidString
  let group: ClassGroupConfig
  let isDefault: Bool
}

struct ImageToPredic: Identifiable, Sendable {
  let id: UUID
  let imageData: Data
  var predictedClass: PredictionClasses?
  var error: String?
}

enum PredictionFlows {
  case initial
  case creatingSession
  case addingGroupConfig
  case addingImages
  case savingSessionModel
  case predicting
}

final class ProcessMediaViewModel: ObservableObject {
  private let modelDataSource: PredictionModelDataSource
  let images: [VideoFrameResult]
  let videoUrl: URL?

  @Published var pickers: [ProcessMediaPicker] = []
  @Published var selectedPickerId: String = ""
  var selectedPickerItem: ProcessMediaPicker? = nil
  @Published var processingState: MediaProcessingState = .idle
  @Published var processingMessage: String?
  @Published var errorMesaage: String? = nil
  @Published var groupConfigMessage: String? = nil
  @Published var buttonTitle: String = "Save"
  @Published var buttonDisabled: Bool = true
  var onComplete: ((PredictionSessionModel) -> Void)? = nil

  private var userPredictionType = PredictionType.cloudAI
  private var defaultModel: SavedModel?
  private var currentModelSession: PredictionSessionModel?

  @Published private var currentFlowState: PredictionFlows = .initial

  private var cancellables: Set<AnyCancellable> = []

  init(
    modelDataSource: PredictionModelDataSource,
    images: [VideoFrameResult],
    videoUrl: URL?,
    currentModelSession: PredictionSessionModel? = nil
  ) {
    self.modelDataSource = modelDataSource
    self.images = images
    self.videoUrl = videoUrl
    self.currentModelSession = currentModelSession
    fetch()
    observe()
  }

  private func observe() {
    $selectedPickerId
      .dropFirst()
      .sink { current in
        guard !current.isEmpty else {
          return
        }
        self.selectedPickerItem = self.pickers.first { $0.id == current }
      }
      .store(in: &cancellables)

    $currentFlowState
      .sink { current in
        switch current {
        case .initial:
          print("Nothing to do here")
        case .creatingSession:
          self.creatingSession()
        case .addingGroupConfig:
          self.addingGroupConfiguration()
        case .addingImages:
          self.addingImages()
        case .savingSessionModel:
          self.savingSessionModel()
        case .predicting:
          self.predicting()
        }
      }
      .store(in: &cancellables)
  }

  private func fetch() {
    let userDefaults = UserDefaults.standard
    guard
      let predictionConfiguration = userDefaults.predictionConfiguration,
      let userPreference = userDefaults.userPreference else {
      return
    }

    userPredictionType = userPreference.preferredPredictionType
    defaultModel = userPreference.savedModels.first { $0.isDefault }

    let userGroups = userPreference.savedGroups
      .map { ProcessMediaPicker(group: $0.config, isDefault: $0.isDefault) }

    let hasDefault = userGroups.contains(where: \.isDefault)

    let systemGroups = predictionConfiguration.groups.map {
      ProcessMediaPicker(group: $0, isDefault: !hasDefault)
    }

    var mergedGroups = userGroups + systemGroups
    mergedGroups = mergedGroups.sorted { $0.isDefault && !$1.isDefault }
    self.selectedPickerId = mergedGroups.first?.id ?? ""
    self.selectedPickerItem = mergedGroups.first
    self.pickers = mergedGroups
    self.buttonDisabled = self.selectedPickerItem == nil
  }

  private func updateGroupConfigMessage() {
    guard let currentModelSession, let firstGroup = currentModelSession.predictionGroups.first else {
      return
    }

    self.groupConfigMessage = firstGroup.name
  }

  private func creatingSession() {
    self.processingMessage = "Preparing session..."

    let session = createSessionModel()
    print("Session Model Created")

    currentModelSession = session
    currentFlowState = .addingGroupConfig
  }

  private func addingGroupConfiguration() {
    guard var session = currentModelSession, let selectedPickerItem = self.selectedPickerItem else {
      self.processingState = .failed
      self.errorMesaage = "No session model to add group config to."
      return
    }
    self.processingMessage = "Adding group configuration to session..."
    self.buttonTitle = "Processing..."

    session = addGroupConfiguration(to: session, from: selectedPickerItem.group)
    print("Group config added")
    currentModelSession = session
    currentFlowState = .addingImages
  }

  private func addingImages() {
    guard var session = currentModelSession else {
      self.processingState = .failed
      self.errorMesaage = "No session model to add images to."
      return
    }

    self.buttonTitle = "Processing..."

    let suffix = videoUrl == nil ? "image" : "video frame"
    self.processingMessage = "Adding \(suffix)(s) to session..."

    session = addImagesToSessionModel(to: session)
    currentModelSession = session
    currentFlowState = .savingSessionModel
  }

  private func savingSessionModel() {
    guard let session = currentModelSession else {
      self.processingState = .failed
      self.errorMesaage = "No session model to save."
      return
    }

    self.buttonTitle = "Processing..."

    do {
      modelDataSource.insertSessionModel(session)
      try modelDataSource.saveSessionModel()
      self.currentFlowState = .predicting
    } catch {
      self.errorMesaage = "Error saving session model: \(error.localizedDescription)"
      self.processingState = .failed
      self.buttonDisabled = false
      self.buttonTitle = "Retry"
    }
  }

  private func predicting() {
    guard let session = currentModelSession else {
      self.processingState = .failed
      self.errorMesaage = "No session model to predict with."
      return
    }
    self.buttonTitle = "Processing..."

    if userPredictionType == .cloudAI {
      processCloudAIImagePredictions(using: session)
    } else {
      processOnDeviceAIImagePredictions()
    }

    onComplete?(session)
  }

  func attemptProcessing() {
    guard let _ = self.selectedPickerItem else {
      errorMesaage = "Please choose a group."
      return
    }

    self.buttonDisabled = true

    if currentFlowState == .initial {
      self.currentFlowState = .creatingSession
    } else {
      // Retry mechanism
      self.currentFlowState = self.currentFlowState
    }
  }

  private func processCloudAIImagePredictions(using session: PredictionSessionModel) {
    //
  }

  private func getModelPath(from model: SavedModel) throws -> String {
    // Get the documents directory url
    let path = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    ).appendingPathComponent("tflite_models", isDirectory: true)

    return path
      .appendingPathComponent("v\(model.model.version)")
      .appendingPathExtension("tflite")
      .path()
  }

  private func processOnDeviceAIImagePredictions() {
    guard let defaultModel, let session = currentModelSession else {
      self.errorMesaage = "Please set a default model in settings, and afterwards you can try again."
      self.processingState = .failed
      return
    }

    do {
      let path = try getModelPath(from: defaultModel)
      guard let tfliteInterpreter = TFLiteModel(modelPath: path) else {
        self.errorMesaage = "Please set a default model in settings, and afterwards you can try again."
        self.processingState = .failed
        return
      }

      let allGroups = session.predictionGroups.map(\.classes).flatMap(\.self)

      var failedData: [UUID: String] = [:]
      for image in session.images {
        let result = tfliteInterpreter.runInference(inputData: image.resizedData)
        switch result {
        case .failure(let error):
          failedData[image.id] = error.errorInformation
        case .success(let prediction):
          if let firstGroup = allGroups.first(
            where: { prediction.classification.name == $0.name
            }) {
            image.predictedClass = firstGroup
          } else {
            failedData[image.id] = "No matching class found"
          }
        }
      }

      if failedData.isEmpty {
        session.predictionState = .done
        self.processingMessage = "Image predictions completed successfully."
      }

      try modelDataSource.saveSessionModel()
    } catch {
      self.processingState = .failed
      self.buttonDisabled = false
      self.buttonTitle = "Retry"
    }
  }

  private func createSessionModel() -> PredictionSessionModel {
    // Get formatted date and time in UTC
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//    formatter.timeZone = TimeZone(secondsFromGMT: 0)
//    let currentDateTime = formatter.string(from: Date())
    let mediaType = videoUrl != nil ? SessionPredictionMediaType.video : SessionPredictionMediaType.image
    let predictionType = userPredictionType == .cloudAI ? SessionPredictionType.cloudAI : SessionPredictionType.onDeviceAI
    let currentDate = Date()
    let model = PredictionSessionModel(
      id: UUID(),
      date: currentDate,
      predictionState: SessionPredictionState.pending,
      numberOfImages: images.count,
      mediaType: mediaType,
      predictionType: predictionType,
      videoPath: videoUrl?.path(),
      images: []
    )

    return model
  }

  private func addGroupConfiguration(
    to sessionModel: PredictionSessionModel,
    from group: ClassGroupConfig
  ) -> PredictionSessionModel {
    let currentSession = sessionModel
    let allGroup = group.groupConfig.map { current in
      let allClass = current.classes.map { classInfo in
        return SessionGroupClass(
          id: UUID(),
          name: classInfo.name,
          displayName: classInfo.description,
          classDescription: classInfo.description
        )
      }

      return PredictionSessionGroup(
        id: UUID(),
        name: current.name,
        localGroupName: group.name,
        classes: allClass,
        session: currentSession
      )
    }

    currentSession.predictionGroups = allGroup

    return currentSession
  }

  private func addImagesToSessionModel(to sessionModel: PredictionSessionModel) -> PredictionSessionModel {
    let mediaType = videoUrl != nil ? SessionPredictionMediaType.video : SessionPredictionMediaType.image
    let currentSession = sessionModel

    let allImage = images.map { currentImage in
      return PredictionSessionMedia(
        id: UUID(),
        name: UUID().uuidString,
        mediaType: mediaType,
        data: currentImage.data,
        resizedData: currentImage.resizedData,
        session: currentSession
      )
    }

    currentSession.images = allImage
    return currentSession
  }
}

