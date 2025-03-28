//
//  HomeViewModel.swift
//  Home
//
//  Created by Abubakar Oladeji on 09/02/2025.
//

import SwiftUI
import Assets
import Combine
import Factory
import Foundation
import Platform
import SwiftData

enum ViewSessionModelState: Sendable, Identifiable {
  var id: Self { self }
  case reviewed
  case unReviewed
  case failedProcessing

  var title: String {
    switch self {
    case .reviewed:
      return "Reviewed"
    case .unReviewed:
      return "UnReviewed"
    case .failedProcessing:
      return "Failed Processing"
    }
  }
}

struct ViewSessionSection: Sendable, Identifiable {
  let id: UUID = UUID()
  let type: ViewSessionModelState
  let models: [ViewSessionModel]

  init(type: ViewSessionModelState, models: [ViewSessionModel]) {
    self.type = type
    self.models = models
  }
}

struct ViewSessionModel: Sendable, Identifiable {
  let id: UUID = UUID()
  let when: String
  let reviewPercentage: Double
  let accuracyTitle: String
  let mediaType: String
  let accuracy: Double
  let groupName: String
  let state: ViewSessionModelState
  let imagesPreview: [Data]
  let totalImagCount: Int
  let imageText: String
  let modelId: UUID

  init(
    when: String,
    reviewPercentage: Double,
    accuracyTitle: String,
    accuracy: Double,
    groupName: String,
    state: ViewSessionModelState,
    imagesPreview: [Data],
    totalImagCount: Int,
    imageText: String,
    mediaType: String,
    modelId: UUID
  ) {
    self.when = when
    self.reviewPercentage = reviewPercentage
    self.accuracyTitle = accuracyTitle
    self.accuracy = accuracy
    self.groupName = groupName
    self.state = state
    self.imagesPreview = imagesPreview
    self.totalImagCount = totalImagCount
    self.imageText = imageText
    self.modelId = modelId
    self.mediaType = mediaType
  }

  var images: [UIImage] {
    imagesPreview.compactMap(UIImage.init)
  }
}

enum FilePickerFlow: String, Identifiable {
  var id: Self { self }
  case image
  case video
  case mediaAlbum
  case documentPicker

  case photoInAlbum
  case photoInDocument
  case videoInAlbum
  case videoInDocument

  case unknown

  var title: String {
    switch self {
    case .image: "Image"
    case .video: "Video"
    case .mediaAlbum: "Media Album"
    case .documentPicker: "Document Picker"
    default: ""
    }
  }
}

public final class HomeViewModel: ObservableObject {
  private let downloadManager: DownloadManager
  let predictionService: PredictionAPIService

  @Published var isDownloadInProgress: Bool = false
  @Published var isDownloadCompleted: Bool = false
  @Published var downloadedModelVersion: String = ""
  @Published var progress: Double = 0
  @Published var isMenueOpen: Bool = false

  @Published var showMediaPicker: Bool = false
  @Published var finalMediaOption: FilePickerFlow = .unknown
  @Published var showMediaAlbumOrDocumentPicker: Bool = false
  @Published var mediaResult: EcoAlbumPickerResult?
  @Published var selectedImages: [VideoFrameResult] = []
  @Published var selectedVideoUrl: URL?

  @Published var showProcessingUI: Bool = false
  @Published var progressMessage: String?
  @Published var showSessionReviewScreen: Bool = false

  @Published var selectedSession: ViewSessionModel?

  private var subscriptions = Set<AnyCancellable>()

  private var modelContext: ModelContext?
  private(set) var modelDataSource: PredictionModelDataSource?

  public init(downloadManager: DownloadManager, predictionService: PredictionAPIService) {
    self.downloadManager = downloadManager
    self.predictionService = predictionService
    observe()
  }

  func setModelContext(_ context: ModelContext) {
    self.modelContext = context
    self.modelDataSource = PredictionModelDataSource(context)
  }

  private func observe() {
    downloadManager.$isDownloadInProgress.sink { [weak self] isInProgress in
      self?.isDownloadInProgress = isInProgress
    }.store(in: &subscriptions)

    downloadManager.$progress.sink { [weak self] downloadProgress in
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

    $finalMediaOption
      .dropFirst()
      .sink { [weak self] selectedOption in
        // Process flow
        print("Selected option: \(selectedOption)")
        self?.showMediaPicker = false
        self?.showMediaAlbumOrDocumentPicker = true
      }
      .store(in: &subscriptions)

    $mediaResult
      .dropFirst()
      .sink { result in
        self.showMediaAlbumOrDocumentPicker = false
        self.progressMessage = nil
        guard let result else { return }
        switch result {
        case .processing(let processing):
          print("Processing: ", processing)
          self.progressMessage = processing
        case .failed(let error):
          print("Error: \(error)")
        case .cancelled:
          print("User cancelled the operation.")
        case .images(let images):
          self.selectedImages = images
          self.selectedVideoUrl = nil
          self.showProcessingUI = true
        case .video(let url, let frames):
          self.selectedVideoUrl = url
          self.selectedImages = frames
          self.showProcessingUI = true
        }
      }
      .store(in: &subscriptions)

    $showSessionReviewScreen
      .dropFirst()
      .sink { status in
        if !status { self.stopProcessingImages() }
      }.store(in: &subscriptions)
  }

  func handleSessions(_ sessions: [PredictionSessionModel]) -> [ViewSessionSection] {
    var reviewedSection = [ViewSessionModel]()
    var unreviewedSection = [ViewSessionModel]()
    var failedSection = [ViewSessionModel]()

    for session in sessions {
      let dateFormatter = DateFormatter()
      dateFormatter.locale = Locale(identifier: "en_US_POSIX")
      let locale = Locale.current
      if let format = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale) {
        if format.contains("a") {
          dateFormatter.dateFormat = "dd MMM yyyy 'at' hh:mm a"
        } else {
          dateFormatter.dateFormat = "dd MMM yyyy 'at' HH:mm"
        }
      }
      let currentDateString = dateFormatter.string(from: session.date)

      // Calculate review percentage
      let imageCount = session.images.count
      let reviewedCount = session.images.filter { $0.actualClass != nil }.count
      let predictedCount = session.images.filter { $0.predictedClass != nil }.count
      let accuratePredictedCount = session.images.filter {
        $0.isPredictionAccurate && $0.actualClass != nil
      }.count
      let reviewPercentage = Double(reviewedCount) / Double(imageCount) * 100
      let accuracyPercentage = Double(accuratePredictedCount) / Double(predictedCount) * 100

      // Set

      // Set Media Type
      let mediaType = session.videoPath != nil ? "Video" : "Image"

      // Local Group Information
      let localGroupName = session.predictionGroups.first?.localGroupName ?? "Unknown"

      // Images to preview
      let allImages = session.images.map(\.data)
      let firstFive: [Data] = allImages.enumerated().prefix(5).map(\.1)
      let suffix = session.videoPath != nil ? "frame" : "image"
      let imageText = imageCount == 1 ? "\(imageCount) \(suffix)" : "\(imageCount) \(suffix)s"

      let sessionState = predictedCount != imageCount ? ViewSessionModelState.failedProcessing : reviewedCount != imageCount ? ViewSessionModelState.unReviewed : .reviewed

      let finalModel = ViewSessionModel(
        when: currentDateString,
        reviewPercentage: reviewPercentage,
        accuracyTitle: "Accuracy",
        accuracy: accuracyPercentage,
        groupName: localGroupName,
        state: sessionState,
        imagesPreview: firstFive,
        totalImagCount: imageCount,
        imageText: imageText,
        mediaType: mediaType,
        modelId: session.id
      )

      switch sessionState {
      case .failedProcessing:
        failedSection.append(finalModel)
      case .unReviewed:
        unreviewedSection.append(finalModel)
      case .reviewed:
        reviewedSection.append(finalModel)
      }
    }

    var section = [ViewSessionSection]()
    if !failedSection.isEmpty {
      section
        .append(
          ViewSessionSection(type: .failedProcessing, models: failedSection)
        )
    }

    if !unreviewedSection.isEmpty {
      section
        .append(
          ViewSessionSection(type: .unReviewed, models: unreviewedSection)
        )
    }
    if !reviewedSection.isEmpty {
      section
        .append(
          ViewSessionSection(type: .reviewed, models: reviewedSection)
        )
    }

    return section
  }

  func stopProcessingImages() {
    self.mediaResult = nil
    self.selectedImages = []
    self.selectedVideoUrl = nil
    self.showProcessingUI = false
    self.selectedSession = nil
  }
}

