//
//  MultiSelectionSheet.swift
//  Settings
//
//  Created by Abubakar Oladeji on 18/03/2025.
//

import Assets
import Foundation
import SwiftUI

struct MultiSelectionSheet: View {
  private let items: [AddCategoryClassInfo]
  private let onSave: ([AddCategoryClassInfo]) -> Void
  private let onDismiss: () -> Void
  @Environment(\.dismiss) private var dismiss

  @State private var selectedItems = Set<String>()

  var body: some View {
    NavigationView {
      List(items, selection: $selectedItems) { item in
        HStack {
          Text(item.classInfo.readableName)
            .font(Font.EcoSort.body)
            .foregroundColor(.EcoSort.Text.text4)

          if let subtitle = item.existingSection {
            Text("(\(subtitle))")
              .font(Font.EcoSort.bodyS)
              .foregroundColor(.EcoSort.Text.text3)
          }
        }
      }
      .environment(\.editMode, .constant(.active))
      .navigationTitle("Select Items")
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button {
            let selectedItemsArray: [AddCategoryClassInfo] = self.items.filter {
              self.selectedItems.contains($0.id)
            }

            onSave(selectedItemsArray)
            dismiss()
          } label: {
            Text("Save")
          }
        }

        ToolbarItem(placement: .cancellationAction) {
          Button {
            dismiss()
            onDismiss()
          } label: {
            Text("Cancel")
          }
        }
      }
    }
  }

  init(
    items: [AddCategoryClassInfo],
    onSave: @escaping ([AddCategoryClassInfo]) -> Void,
    onDismiss: @escaping () -> Void
  ) {
    self.items = items
    self.onSave = onSave
    self.onDismiss = onDismiss
  }
}
