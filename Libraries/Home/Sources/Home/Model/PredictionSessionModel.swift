//
//  PredictionSessionModel.swift
//  Home
//
//  Created by Abubakar Oladeji on 19/03/2025.
//

import Foundation
import SwiftData

public enum SessionPredictionState: String, Codable {
  case pending
  case inProgress
  case done
}

public enum SessionPredictionMediaType: String, Codable {
  case image
  case video
}

public enum SessionPredictionType: String, Codable {
  case onDeviceAI
  case cloudAI
}

@Model
public final class PredictionSessionModel {
  @Attribute(.unique) public var id: UUID
  var date: Date
  var predictionState: SessionPredictionState
  var numberOfImages: Int
  var mediaType: SessionPredictionMediaType
  var predictionType: SessionPredictionType
  var finalAccuracy: Double?
  var preliminaryAccuracy: Double?
  var reviewCompletion: Double?

  var videoPath: String?
  var videoDuration: TimeInterval?

  @Relationship(deleteRule: .cascade, inverse: \PredictionSessionGroup.session)
  var predictionGroups = [PredictionSessionGroup]()
  @Relationship(deleteRule: .cascade, inverse: \PredictionSessionMedia.session)
  var images: [PredictionSessionMedia]

  public init(
    id: UUID,
    date: Date,
    predictionState: SessionPredictionState,
    numberOfImages: Int,
    mediaType: SessionPredictionMediaType,
    predictionType: SessionPredictionType,
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
    self.predictionType = predictionType
    self.finalAccuracy = finalAccuracy
    self.preliminaryAccuracy = preliminaryAccuracy
    self.reviewCompletion = reviewCompletion
    self.videoPath = videoPath
    self.videoDuration = videoDuration
    self.predictionGroups = predictionGroups
    self.images = images
  }
}
