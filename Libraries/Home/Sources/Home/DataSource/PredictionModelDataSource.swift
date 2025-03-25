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

  func fetchSessions() throws -> [PredictionSessionModel] {
    try modelContext.fetch(FetchDescriptor<PredictionSessionModel>())
  }

  func fetchSession(with identifier: UUID) throws -> PredictionSessionModel? {
    var descriptor = FetchDescriptor<PredictionSessionModel>(
      predicate: #Predicate { $0.id == identifier }
    )
    descriptor.fetchLimit = 1
    let result = try modelContext.fetch(descriptor)
    return result.first
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
