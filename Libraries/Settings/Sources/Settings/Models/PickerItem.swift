//
//  PickerItem.swift
//  Settings
//
//  Created by Abubakar Oladeji on 17/03/2025.
//

import Foundation
import Platform

enum ToolbarAction: String, Identifiable {
  var id: Self { self }
  case add
  case edit
  case delete
  case save
  case favorite
  case unFavorite

  var title: String {
    switch self {
    case .add:
      return "Add"
    case .edit:
      return "Edit"
    case .delete:
      return "Delete"
    case .save:
      return "Save"
    case .favorite:
      return "Favorite"
    case .unFavorite:
      return "UnFavorite"
    }
  }

  var systemImageName: String {
    switch self {
    case .add:
      return "plus"
    case .edit:
      return "pencil"
    case .delete:
      return "trash"
    case .save:
      return "checkmark"
    case .favorite:
      return "star"
    case .unFavorite:
      return "star.fill"
    }
  }
}

struct PickerItem: Identifiable, Encodable, Hashable {
  let id = UUID().uuidString
  let label: String
  var content: [CategorySection]
  let isDefault: Bool
  let canEdit: Bool

  var customListSection: [ListCategorySection] {
    var items: [ListCategorySection] = []
    for (sectionIndex, section) in content.enumerated() {
      items.append(
        ListCategorySection(
          sectionName: section.name,
          isHeader: true,
          indexInfo: SectionIndex(
            section: sectionIndex
          )
        )
      )
      for (_, item) in section.items.enumerated() {
        items.append(
          ListCategorySection(
            sectionName: section.name,
            classInfo: item.classInfo,
            indexInfo: SectionIndex(
              section: sectionIndex
            )
          )
        )
      }
    }
    return items
  }

  init(
    label: String,
    content: [CategorySection],
    isDefault: Bool,
    canDefaultBeChanged: Bool = false,
    canEdit: Bool = false
  ) {
    self.label = label
    self.content = content
    self.isDefault = isDefault
    self.canEdit = canEdit
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
