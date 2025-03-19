//
//  ManageModelScreen.swift
//  Settings
//
//  Created by Abubakar Oladeji on 02/03/2025.
//

import Assets
import SwiftUI

struct ManageModelScreen: View {
  @EnvironmentObject private var viewModel: ManageModelsViewModel
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: .multiplier(7)) {
        predictionType

        if !viewModel.models.isEmpty {
          modelOptions
        }
      }
      .animation(.easeInOut, value: viewModel.models)
    }
    .scrollIndicators(.hidden)
    .toolbar {
      ToolbarItem {
        Button {
          viewModel.saveModelConfiguration()
          dismiss()
        } label: {
          Text("Save")
            .font(Font.EcoSort.title3)
            .foregroundStyle(Color.EcoSort.Text.text5)
            .lineSpacing(AppPadding.custom(11).value)
        }
        .disabled(!viewModel.canUserSave)
      }
    }
    .onAppear() {
      Task {
        await self.viewModel.loadConfig()
      }
    }
    .refreshable {
      await self.viewModel.loadConfig()
    }
  }

  private var predictionType: some View {
    VStack(alignment: .leading, spacing: .large) {
      Text("Prediction mode")
        .font(Font.EcoSort.headingXL)
        .foregroundStyle(Color.EcoSort.Text.text5)
        .lineSpacing(AppPadding.custom(11).value)
        .padding([.leading, .trailing], AppPadding.medium.value)

      VStack(alignment: .leading, spacing: .medium) {
        ForEach(viewModel.predictionTypes) { predictionType in
          ModelOptionView(
            title: predictionType.type.title,
            subtitle: predictionType.type.description,
            selected: predictionType.selected
          )
          .frame(maxWidth: .infinity)
          .onTapGesture {
            viewModel.updateSelectedPredictionType(predictionType.type)
          }
        }
      }
    }
  }

  private var modelOptions: some View {
    VStack(alignment: .leading, spacing: .large) {
      Text("Models")
        .font(Font.EcoSort.headingXL)
        .foregroundStyle(Color.EcoSort.Text.text5)
        .lineSpacing(AppPadding.custom(11).value)
        .padding([.leading, .trailing], AppPadding.medium.value)

      VStack(alignment: .leading, spacing: .medium) {
        ForEach(viewModel.models) { model in
          ManageModelItem(model: model)
            .environmentObject(viewModel)
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing], AppPadding.medium.value)
        }
      }
    }
  }
}
