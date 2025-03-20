//
//  PredictionSessionModel.swift
//  Home
//
//  Created by Abubakar Oladeji on 19/03/2025.
//

import Foundation
import SwiftData

enum PredictionState: String, Codable {
  case pending
  case inProgress
  case done
}

enum PredictionMediaType: String, Codable {
  case image
  case video
}

@Model
final class PredictionSessionModel {
  @Attribute(.unique) var id: UUID
  var date: Date
  var predictionState: PredictionState
  var numberOfImages: Int
  var mediaType: PredictionMediaType
  var finalAccuracy: Double?
  var preliminaryAccuracy: Double?
  var reviewCompletion: Double?

  var videoPath: String?
  var videoDuration: TimeInterval?

  @Relationship(deleteRule: .cascade, inverse: \PredictionSessionGroup.session)
  var predictionGroups = [PredictionSessionGroup]()
  @Relationship(deleteRule: .cascade, inverse: \PredictionSessionMedia.session)
  var images: [PredictionSessionMedia]

  init(
    id: UUID,
    date: Date,
    predictionState: PredictionState,
    numberOfImages: Int,
    mediaType: PredictionMediaType,
    finalAccuracy: Double? = nil,
    preliminaryAccuracy: Double? = nil,
    reviewCompletion: Double? = nil,
    videoPath: String? = nil,
    videoDuration: TimeInterval? = nil,
    predictionGroups: [PredictionSessionGroup] = [PredictionSessionGroup](),
    images: [PredictionSessionMedia]
  ) {
    self.id = id
    self.date = date
    self.predictionState = predictionState
    self.numberOfImages = numberOfImages
    self.mediaType = mediaType
    self.finalAccuracy = finalAccuracy
    self.preliminaryAccuracy = preliminaryAccuracy
    self.reviewCompletion = reviewCompletion
    self.videoPath = videoPath
    self.videoDuration = videoDuration
    self.predictionGroups = predictionGroups
    self.images = images
  }
}
