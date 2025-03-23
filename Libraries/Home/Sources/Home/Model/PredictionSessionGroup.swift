//
//  PredictionSessionGroup.swift
//  Home
//
//  Created by Abubakar Oladeji on 19/03/2025.
//

import Foundation
import SwiftData

@Model
public final class PredictionSessionGroup {
  @Attribute(.unique) public var id: UUID
  var name: String
  var localGroupName: String
  @Relationship(deleteRule: .cascade, inverse: \SessionGroupClass.group)
  var classes = [SessionGroupClass]()
  var session: PredictionSessionModel?

  public init(
    id: UUID,
    name: String,
    localGroupName: String,
    classes: [SessionGroupClass] = [SessionGroupClass](),
    session: PredictionSessionModel? = nil
  ) {
    self.id = id
    self.name = name
    self.localGroupName = localGroupName
    self.classes = classes
    self.session = session
  }
}

@Model
public final class SessionGroupClass {
  @Attribute(.unique) public var id: UUID
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
