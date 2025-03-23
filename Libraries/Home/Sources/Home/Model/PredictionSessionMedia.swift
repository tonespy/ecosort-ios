//
//  PredictionSessionImage.swift
//  Home
//
//  Created by Abubakar Oladeji on 19/03/2025.
//

import Foundation
import SwiftData

@Model
public final class PredictionSessionMedia {
  @Attribute(.unique) public var id: UUID
  @Attribute(.unique) var name: String
  var mediaType: SessionPredictionMediaType
  @Attribute(.externalStorage) var data: Data
  @Attribute(.externalStorage) var resizedData: Data

  var session: PredictionSessionModel?

  var predictedClass: SessionGroupClass?
  var actualClass: SessionGroupClass?
  var isPredictionAccurate: Bool {
    predictedClass?.id == actualClass?.id
  }

  init(
    id: UUID,
    name: String,
    mediaType: SessionPredictionMediaType,
    data: Data,
    resizedData: Data,
    session: PredictionSessionModel? = nil,
    predictedClass: SessionGroupClass? = nil,
    actualClass: SessionGroupClass? = nil
  ) {
    self.id = id
    self.name = name
    self.mediaType = mediaType
    self.data = data
    self.resizedData = resizedData
    self.session = session
    self.predictedClass = predictedClass
    self.actualClass = actualClass
  }
}
