//
//  ManageCategories.swift
//  Settings
//
//  Created by Abubakar Oladeji on 02/03/2025.
//

import Assets
import SwiftUI

struct ManageCategories: View {
  @EnvironmentObject private var viewModel: ManageCategoriesViewModel
  @State var selectedOption: String = "almere"

  var body: some View {
    ZStack {
      Color.EcoSort.Base.background
        .ignoresSafeArea()
      List {
//        categoryInput
        Picker("Classification Groups", selection: $selectedOption) {
          Text("Default").tag("default")
          Text("Almere").tag("almere")
          Text("Delft").tag("delft")
          Text("Rotterdam").tag("rotterdam")
        }
        .background(Color.EcoSort.Base.white)
        .font(Font.EcoSort.body1)
        .foregroundColor(.EcoSort.Text.text5)
        .pickerStyle(.menu)
      }
      .listStyle(.grouped)
      .background(Color.EcoSort.Base.background)
      .scrollContentBackground(.hidden)
    }
    .toolbarBackground(Color.EcoSort.Base.background, for: .navigationBar)
  }

  private var categoryInput: some View {
    HStack(spacing: SpacingSize.medium.value) {
      TextField(
        "Enter comma-separated grouping...",
        text: $viewModel.groups
      )
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
      .font(Font.EcoSort.bodyS)

      Button {} label: {
        Text("Save")
          .font(Font.EcoSort.body)
          .foregroundColor(.EcoSort.Text.textO)
          .padding()
          .disabled(viewModel.groups.count == 0)
          .background(
            RoundedRectangle(cornerRadius: SpacingSize.small.value)
              .fill(Color.EcoSort.Button.primary)
          )
      }
    }
    .textFieldStyle(OutlinedTextFieldStyle())
    .padding()
  }
}
