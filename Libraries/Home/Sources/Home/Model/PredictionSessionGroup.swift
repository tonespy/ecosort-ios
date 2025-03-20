//
//  PredictionSessionGroup.swift
//  Home
//
//  Created by Abubakar Oladeji on 19/03/2025.
//

import Foundation
import SwiftData

@Model
final class PredictionSessionGroup {
  @Attribute(.unique) var id: UUID
  var name: String
  @Relationship(deleteRule: .cascade, inverse: \SessionGroupClass.group)
  var classes = [SessionGroupClass]()
  var session: PredictionSessionModel?

  init(
    id: UUID,
    name: String,
    classes: [SessionGroupClass] = [SessionGroupClass](),
    session: PredictionSessionModel? = nil
  ) {
    self.id = id
    self.name = name
    self.classes = classes
    self.session = session
  }
}

@Model
final class SessionGroupClass {
  @Attribute(.unique) var id: UUID
  var name: String
  var displayName: String
  var classDescription: String
  var group: PredictionSessionGroup?

  init(id: UUID, name: String, displayName: String, classDescription: String) {
    self.id = id
    self.name = name
    self.displayName = displayName
    self.classDescription = classDescription
  }
}
