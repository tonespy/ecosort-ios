//
//  HomeViewModel.swift
//  Home
//
//  Created by Abubakar Oladeji on 09/02/2025.
//

import Combine
import Factory
import Foundation
import Platform

public final class HomeViewModel: ObservableObject {
  private let downloadManager: DownloadManager
  private let predictionService: PredictionAPIService

  @Published var isDownloadInProgress: Bool = false
  @Published var isDownloadCompleted: Bool = false
  @Published var downloadedModelVersion: String = ""
  @Published var progress: Double = 0
  @Published var isMenueOpen: Bool = false

  private var subscriptions = Set<AnyCancellable>()

  public init(downloadManager: DownloadManager, predictionService: PredictionAPIService) {
    self.downloadManager = downloadManager
    self.predictionService = predictionService
    observe()
  }

  private func observe() {
    downloadManager.$isDownloadInProgress.sink { [weak self] isInProgress in
      self?.isDownloadInProgress = isInProgress
    }.store(in: &subscriptions)

    downloadManager.$progress.sink { [weak self] downloadProgress in
//      print("Home Download Progress: \(downloadProgress)")
      self?.progress = downloadProgress
    }.store(in: &subscriptions)

    downloadManager.completionHandler = { [weak self] location, version, isSaved in
      self?.downloadedModelVersion = " v\(version)"
      self?.isDownloadCompleted = true
      guard let location, isSaved else {
        print("Download completed, but saving failed")
        return
      }

      print("Download completed and saved \(location.path())")
    }

    downloadManager.failureHandler = { [weak self] location, errorInfo, version in
      self?.isDownloadCompleted = false
      print("Download failed: \(errorInfo)")
    }
  }

  private func getDefaultModel() throws -> URL {
    guard let defaultModel = UserDefaults.standard.userPreference?.savedModels.first(
      where: { $0.isDefault
      })?.model else {
      throw NSError(domain: "Default model not found!!!", code: 0, userInfo: nil)
    }

    // Get the documents directory url
    let path = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    ).appendingPathComponent("tflite_models", isDirectory: true)

    return path
      .appendingPathComponent("v\(defaultModel.version)")
      .appendingPathExtension("tflite")
  }

  func runInference(data: Data) {
    guard let modelPath = try? getDefaultModel() else {
      print("Path not present")
      return
    }

    print("Using Path: \(modelPath)")
    guard let model = TFLiteModel(modelPath: modelPath.path()) else {
      print("Failed to load TFLite model.")
      return
     }

    guard let inferenceCheck = model.runInference(inputData: data) else {
      print("Inference failed.")
      return
    }

    print("Output Data: \(inferenceCheck)")
  }
}

