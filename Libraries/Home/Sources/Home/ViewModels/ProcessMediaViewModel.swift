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
import SwiftUI

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

@MainActor
final class ProcessMediaViewModel: ObservableObject {
  private let predictionService: PredictionAPIService
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
  @Published var buttonTitle: String = ""
  @Published var buttonDisabled: Bool = true
  var onComplete: ((String) -> Void)? = nil

  private var userPredictionType = PredictionType.cloudAI
  private var defaultModel: SavedModel?
  private var currentModelSession: PredictionSessionModel?
  let needsRetry: Bool

  private var allImageDict = [String: Data]()

  @Published var currentFlowState: PredictionFlows = .initial

  private var cancellables: Set<AnyCancellable> = []

  init(
    modelDataSource: PredictionModelDataSource,
    images: [VideoFrameResult],
    videoUrl: URL?,
    currentModelSession: UUID? = nil,
    predictionService: PredictionAPIService
  ) {
    self.modelDataSource = modelDataSource
    self.predictionService = predictionService
    self.needsRetry = currentModelSession != nil

    let videoPath: URL?
    if let currentModelSession {
      let session = try? modelDataSource.fetchSession(with: currentModelSession)
      self.currentModelSession = session
      if let session {
        self.images = session.images.map {
          VideoFrameResult(
            data: $0.data,
            resizedData: $0.resizedData,
            image: UIImage(data: $0.data)!
          )
        }
        self.allImageDict = session.images.reduce(into: [:]) { result, element in
          result[element.id.uuidString] = element.data
        }
        videoPath = session.videoPath.flatMap { URL(string: $0) }
        self.groupConfigMessage = session.predictionGroups.first?.name
      } else {
        self.images = []
        videoPath = nil
      }
    } else {
      self.currentModelSession = nil
      self.images = images
      videoPath = videoUrl
    }
    self.videoUrl = videoPath

    fetch()
    observe()
  }

  private func observe() {
    $selectedPickerId
      .dropFirst()
      .sink { [weak self] current in
        // Temporary work around for view not reloading
        guard let self = self, !self.buttonDisabled, !current.isEmpty else { return }
        self.selectedPickerItem = self.pickers.first { $0.id == current }
      }
      .store(in: &cancellables)

    $currentFlowState
      .sink { [weak self] current in
        guard let self = self else { return }
        switch current {
        case .initial:
          print("Nothing to do here")
          self.buttonTitle = "Start prediction"
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

    $buttonTitle.sink { current in
      print("Current Text: ", current)
    }
    .store(in: &cancellables)
  }

  private func fetch() {
    let userDefaults = UserDefaults.standard
    guard
      let predictionConfiguration = userDefaults.predictionConfiguration,
      let userPreference = userDefaults.userPreference
    else {
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

  private func changeButtonState(_ title: String, disabled: Bool) {
    self.buttonTitle = title
    self.buttonDisabled = disabled
  }

  private func creatingSession() {
    self.processingMessage = "Preparing session..."
    changeButtonState("Processing...", disabled: true)
    let session = createSessionModel()
    print("Session Model Created")
    currentModelSession = session
    currentFlowState = .addingGroupConfig
  }

  private func addingGroupConfiguration() {
    guard var session = currentModelSession, let selectedPickerItem = self.selectedPickerItem else {
      processingState = .failed
      errorMesaage = "No session model to add group config to."
      return
    }
    processingMessage = "Adding group configuration to session..."
    changeButtonState("Processing...", disabled: true)
    session = addGroupConfiguration(to: session, from: selectedPickerItem.group)
    print("Group config added")
    currentModelSession = session
    currentFlowState = .addingImages
  }

  private func addingImages() {
    guard var session = currentModelSession else {
      processingState = .failed
      errorMesaage = "No session model to add images to."
      return
    }
    changeButtonState("Processing...", disabled: true)
    let suffix = videoUrl == nil ? "image" : "video frame"
    processingMessage = "Adding \(suffix)(s) to session..."
    session = addImagesToSessionModel(to: session)
    currentModelSession = session
    currentFlowState = .savingSessionModel
  }

  private func savingSessionModel() {
    guard let session = currentModelSession else {
      processingState = .failed
      errorMesaage = "No session model to save."
      return
    }
    changeButtonState("Processing...", disabled: true)
    do {
      modelDataSource.insertSessionModel(session)
      try modelDataSource.saveSessionModel()
      currentFlowState = .predicting
    } catch {
      errorMesaage = "Error saving session model: \(error.localizedDescription)"
      processingState = .failed
      buttonDisabled = false
      buttonTitle = "Retry"
    }
  }

  private func predicting() {
    guard let session = currentModelSession else {
      processingState = .failed
      errorMesaage = "No session model to predict with."
      return
    }
    changeButtonState("Predicting...", disabled: true)
    if userPredictionType == .cloudAI {
      processCloudAIImagePredictions()
    } else {
      processOnDeviceAIImagePredictions()
      onComplete?(session.id.uuidString)
    }
  }

  func attemptProcessing() {
    // A little helper for now
    if buttonDisabled { return }


    guard selectedPickerItem != nil else {
      errorMesaage = "Please choose a group."
      return
    }

    if currentFlowState == .initial {
      currentFlowState = .creatingSession
    } else {
      currentFlowState = self.currentFlowState // retry mechanism
    }
  }

  private func processCloudAIImagePredictions() {
    let images = allImageDict
    Task {
      do {
        self.predictionService.progressHandler = { progress in
          print("Upload progress: \(progress)")
        }
        let result = try await self.predictionService.uploadImages(images)
        self.listenForWebSocketMessages(result.jobID)
      } catch {
        print("Error: \(error)")
        self.showButtonRetry()
      }
    }
  }

  private func showButtonRetry() {
    changeButtonState("Retry", disabled: false)
  }

  private func forceCompletePrediction() {
    guard let session = currentModelSession else { return }
    onComplete?(session.id.uuidString)
  }

  private func listenForWebSocketMessages(_ jobID: String) {
    guard let socketHelper = PredictionWebSocket(jobId: jobID) else {
      forceCompletePrediction()
      return
    }
    socketHelper.connectWebSocket()
    var allPredictions = [WSPrediction]()
    socketHelper.predictionResult = { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        print("Error: \(error)")
        self.showButtonRetry()
      case .update(let prediction):
        allPredictions = prediction.predictions
        if prediction.progress >= 100 {
          self.updateImagesWithPredictionInformation(allPredictions)
        }
      }
    }
  }

  private func updateImagesWithPredictionInformation(_ predictions: [WSPrediction]) {
    guard let newSession = currentModelSession else {
      showButtonRetry()
      return
    }
    let sessionId = newSession.id
    Task {
      do {
        let modelActor = try SessionModelActor()
        _ = try await modelActor.updateSession(withId: sessionId, predictions: predictions)
        onComplete?(sessionId.uuidString)
      } catch {
        print("Error: \(error)")
      }
    }
  }

  private func getModelPath(from model: SavedModel) throws -> String {
    let path = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    ).appendingPathComponent("tflite_models", isDirectory: true)
    return path.appendingPathComponent("v\(model.model.version)")
      .appendingPathExtension("tflite")
      .path()
  }

  private func processOnDeviceAIImagePredictions() {
    guard let defaultModel, let session = currentModelSession else {
      errorMesaage = "Please set a default model in settings, and afterwards you can try again."
      processingState = .failed
      return
    }
    do {
      let path = try getModelPath(from: defaultModel)
      guard let tfliteInterpreter = TFLiteModel(modelPath: path) else {
        errorMesaage = "Please set a default model in settings, and afterwards you can try again."
        processingState = .failed
        return
      }
      let allGroups = session.predictionGroups.map(\.classes).flatMap { $0 }
      var failedData: [UUID: String] = [:]
      for image in session.images {
        let result = tfliteInterpreter.runInference(inputData: image.resizedData)
        switch result {
        case .failure(let error):
          failedData[image.id] = error.errorInformation
        case .success(let prediction):
          if let firstGroup = allGroups.first(where: { prediction.classification.name == $0.name }) {
            image.predictedClass = firstGroup
          } else {
            failedData[image.id] = "No matching class found"
          }
        }
      }
      if failedData.isEmpty {
        session.predictionState = .done
        processingMessage = "Image predictions completed successfully."
      }
      try modelDataSource.saveSessionModel()
    } catch {
      processingState = .failed
      changeButtonState("Retry", disabled: false)
    }
  }

  private func createSessionModel() -> PredictionSessionModel {
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
          displayName: classInfo.readableName,
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
    allImageDict = allImage.reduce(into: [:]) { result, element in
      result[element.id.uuidString] = element.data
    }
    currentSession.images = allImage
    return currentSession
  }
}
