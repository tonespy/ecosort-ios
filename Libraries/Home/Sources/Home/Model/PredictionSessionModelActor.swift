//
//  PredictionSessionModelActor.swift
//  Home
//
//  Created by Abubakar Oladeji on 28/03/2025.
//

import Foundation
import SwiftData

enum SessionPersistenceError: Error {
  case sessionNotFound
}

actor SessionModelActor {

  public nonisolated let modelContainer: ModelContainer
  public nonisolated let modelExecutor: any ModelExecutor

  init() throws {
    let container = try ModelContainer(for: PredictionSessionModel.self)
    let modelContext = ModelContext(container)
    modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
    self.modelContainer = container
  }

  /// Fetches the session with the given id, updates its images based on predictions, and saves the changes.
  /// - Parameters:
  ///   - sessionId: The unique id of the session.
  ///   - predictions: The list of predictions to apply.
  /// - Returns: The session id (as a String) upon successful update.
  func updateSession(withId sessionId: UUID, predictions: [WSPrediction]) throws -> String {
    var descriptor = FetchDescriptor<PredictionSessionModel>(
      predicate: #Predicate { $0.id == sessionId }
    )
    descriptor.fetchLimit = 1
    // Perform the fetch. Adjust the fetch API as needed.
    let sessions: [PredictionSessionModel] = try modelExecutor.modelContext.fetch(
      descriptor
    )

    guard let session = sessions.first else {
      throw SessionPersistenceError.sessionNotFound
    }

    // Perform your update: iterate through predictions and update images.
    let allClasses = session.predictionGroups.flatMap { $0.classes }
    for prediction in predictions {
      guard let classInfo = allClasses.first(where: { $0.name == prediction.prediction.name }) else {
        continue
      }
      for media in session.images {
        if media.id.uuidString == prediction.strippedImageName {
          media.predictedClass = classInfo
        }
      }
    }

    // Save the context. Because context was created within this actor,
    // it’s safe to call save() here.
    try modelExecutor.modelContext.save()
    return session.id.uuidString
  }
}


