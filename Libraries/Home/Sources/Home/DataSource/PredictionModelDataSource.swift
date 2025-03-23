//
//  PredictionModelDataSource.swift
//  Home
//
//  Created by Abubakar Oladeji on 22/03/2025.
//

import Foundation
import SwiftData

final class PredictionModelDataSource {
  private let modelContext: ModelContext

  init(_ modelContext: ModelContext) {
    self.modelContext = modelContext
  }

  func fetchSessionModel() throws -> [PredictionSessionModel] {
    try modelContext.fetch(FetchDescriptor<PredictionSessionModel>())
  }

  func insertSessionModel(_ sessionModel: PredictionSessionModel) {
    modelContext.insert(sessionModel)
  }

  func saveSessionModel() throws {
    try modelContext.save()
  }

  func updatePredictedMedia(for media: PredictionSessionMedia, with predictedClass: SessionGroupClass) throws {
    media.predictedClass = predictedClass
  }

  func updateActualMedia(for media: PredictionSessionMedia, with predictedClass: SessionGroupClass) throws {
    media.predictedClass = predictedClass
  }
}
