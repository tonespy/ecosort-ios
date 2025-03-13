//
//  PredictionModeView.swift
//  Onboarding
//
//  Created by Abubakar Oladeji on 21/01/2025.
//

import Assets
import Platform
import SwiftUI

struct PredictionModeView: View {
  @EnvironmentObject var viewModel: OnboardingViewModel
  @State var selected: Bool = false
  
  @Binding var appState: AppState
  
  var body: some View {
    ZStack {
      VStack {
        content
        action
      }
      
    }.alert(
      isPresented: $viewModel.showAlert,
      viewModel: AlertViewModel(
        title: LocalizedStringKey(viewModel.selectedPredictionType?.title ?? ""),
        message: LocalizedStringKey(viewModel.alertMessage),
        primaryButtonTitle: LocalizedStringKey("OK"),
        primaryButtonAction: {
          self.viewModel.showAlert.toggle()
          self.viewModel.processUserPreference()
          self.appState = .app
        },
        canDismiss: false
      )
    )
  }
  
  private var content: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: .multiplier(7)) {
        headerTexts
          .padding([.leading, .trailing], AppPadding.large.value)
        
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
    .scrollIndicators(.hidden)
    .scrollBounceBehavior(.basedOnSize, axes: [.vertical])
  }
  
  private var action: some View {
    VStack {
      Button(action: { viewModel.next() }) {
        Text("Finish")
          .font(Font.EcoSort.body)
          .foregroundColor(.EcoSort.Text.textO)
          .frame(minWidth: 0, maxWidth: .infinity)
          .padding()
          .background(
            RoundedRectangle(cornerRadius: SpacingSize.small.value)
              .fill(
                viewModel.selectedPredictionType == nil
                ? Color.EcoSort.Button.primaryDisabled
                : Color.EcoSort.Button.primary
              )
          )
      }
      .disabled(viewModel.selectedPredictionType == nil)
    }.padding()
  }
  
  private var headerTexts: some View {
    VStack(alignment: .leading, spacing: .xSmall) {
      Text("Prediction mode")
        .font(Font.EcoSort.headingXL)
        .foregroundStyle(Color.EcoSort.Text.text5)
        .lineSpacing(AppPadding.custom(11).value)
      
      Text("Choose your preferred prediction mode. You can update these preferences later in the settings menu.")
        .font(Font.EcoSort.body)
        .foregroundStyle(Color.EcoSort.Text.text4)
        .lineSpacing(AppPadding.small.value)
    }
  }
}
