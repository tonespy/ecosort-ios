//
//  PredictionSessionImage.swift
//  Home
//
//  Created by Abubakar Oladeji on 19/03/2025.
//

import Foundation
import SwiftData

@Model
final class PredictionSessionMedia {
  @Attribute(.unique) var id: UUID
  @Attribute(.unique) var name: String
  var mediaType: PredictionMediaType
  @Attribute(.externalStorage) var data: Data

  var session: PredictionSessionModel?

  var predictedClass: SessionGroupClass?
  var actualClass: SessionGroupClass?

  init(
    id: UUID,
    name: String,
    mediaType: PredictionMediaType,
    data: Data,
    session: PredictionSessionModel? = nil,
    predictedClass: SessionGroupClass? = nil,
    actualClass: SessionGroupClass? = nil
  ) {
    self.id = id
    self.name = name
    self.mediaType = mediaType
    self.data = data
    self.session = session
    self.predictedClass = predictedClass
    self.actualClass = actualClass
  }
}
