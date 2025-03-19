//
//  AddCategoryView.swift
//  Settings
//
//  Created by Abubakar Oladeji on 16/03/2025.
//

import Assets
import Foundation
import SwiftUI

struct AddCategoryView: View {
  @EnvironmentObject private var viewModel: AddCategoryViewModel
  @State private var setAsDefault: Bool = false
  @Binding var saveData: (name: String, sectionList: [String], setAsDefault: Bool)?
  @Binding var closeView: Bool

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: SpacingSize.medium) {
          VStack(alignment: .leading, spacing: SpacingSize.small) {
            Text("Name")
              .font(Font.EcoSort.headingS)
              .foregroundColor(.EcoSort.Text.text5)
              .lineSpacing(AppPadding.small.value)

            TextField("Category Name", text: $viewModel.name)
              .disableAutocorrection(true)
              .font(Font.EcoSort.bodyS)
          }

          VStack(alignment: .leading, spacing: SpacingSize.small) {
            Text("Sections")
              .font(Font.EcoSort.headingS)
              .foregroundColor(.EcoSort.Text.text5)
              .lineSpacing(AppPadding.small.value)

            TextField("Comma separated list of sections(i.e: Black Bin, Blue Bin, Green Bin)", text: $viewModel.sections)
              .disableAutocorrection(true)
              .font(Font.EcoSort.bodyS)
              .showClearButton($viewModel.sections)
          }

          Toggle("Set as default", isOn: $setAsDefault)
            .toggleStyle(SwitchToggleStyle(tint: Color.EcoSort.Button.primary))

          Button {
            saveData = (viewModel.name, viewModel.sectionList, setAsDefault)
          } label: {
            Text("Save")
              .font(Font.EcoSort.body)
              .foregroundColor(.EcoSort.Text.textO)
              .frame(minWidth: 0, maxWidth: .infinity)
              .padding()
              .background(
                RoundedRectangle(cornerRadius: SpacingSize.small.value)
                  .fill(
                    viewModel.disableSave ? Color.EcoSort.Button.primaryDisabled : Color.EcoSort.Button.primary
                  )
              )
          }
          .disabled(viewModel.disableSave)
        }
        .padding(SpacingSize.medium.value)
        .textFieldStyle(OutlinedTextFieldStyle())
      }
      .scrollIndicators(.hidden)
      .background(Color.EcoSort.Base.background)
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Add Category")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            closeView.toggle()
          } label: {
            Image(systemName: "xmark")
              .font(Font.EcoSort.title3)
              .foregroundStyle(Color.EcoSort.Text.text5)
          }
        }
      }
    }
  }

  init(
    saveData: Binding<(name: String, sectionList: [String], setAsDefault: Bool)?>,
    closeView: Binding<Bool>
  ) {
    _saveData = saveData
    _closeView = closeView
  }
}

// Extract from here
// https://stackoverflow.com/a/76068569
struct ClearTextFiledButton: ViewModifier {

  @Binding var text: String
  @FocusState private var showDeleteButton: Bool

  func body(content: Content) -> some View {
    content
      .focused($showDeleteButton)
      .overlay(alignment: .trailing) {
        if showDeleteButton {
          Button {
            text = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(Color.EcoSort.Button.primary)
          }
          .padding(.trailing,8)
          .opacity(text.isEmpty ? 0 : 1)
        }
      }
  }
}

extension View {
  func showClearButton(_ text: Binding<String>) -> some View {
    return self.modifier(ClearTextFiledButton(text: text))
  }
}
