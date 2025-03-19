//
//  CategorySection.swift
//  Settings
//
//  Created by Abubakar Oladeji on 17/03/2025.
//

import Foundation
import Platform

struct CategoryItem: Identifiable, Encodable, Hashable {
  let id = UUID().uuidString
  let classInfo: PredictionClasses

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct CategorySection: Identifiable, Encodable, Hashable {
  let id = UUID().uuidString
  let name: String
  var items: [CategoryItem]

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct SectionIndex: Hashable, Encodable {
  let section: Int
}

struct ListCategorySection: Identifiable, Encodable, Hashable {
  let id = UUID().uuidString
  let sectionName: String
  let isHeader: Bool
  let classInfo: PredictionClasses?
  var indexInfo: SectionIndex

  init(
    sectionName: String,
    isHeader: Bool = false,
    classInfo: PredictionClasses? = nil,
    indexInfo: SectionIndex
  ) {
    self.sectionName = sectionName
    self.isHeader = isHeader
    self.classInfo = classInfo
    self.indexInfo = indexInfo
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
