//
//  OnboardingScreen.swift
//  EcoSort
//
//  Created by Abubakar Oladeji on 13/01/2025.
//

import Assets
import Platform
import SwiftUI

public struct OnboardingScreen: View {
  @ObservedObject private var viewModel: OnboardingViewModel
  
  @Binding var appState: AppState
  
  public var body: some View {
    ZStack {
      Color.EcoSort.Base.background
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
      
      if viewModel.flowStage == .information {
        InformationView()
          .environmentObject(viewModel)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
      }
      
      if viewModel.flowStage == .predictionMode {
        PredictionModeView(appState: $appState)
          .environmentObject(viewModel)
          .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
      }
    }
    .background(Color.EcoSort.Base.background)
    .animation(.easeInOut, value: viewModel.flowStage)
    .onAppear() {
      //
    }
  }
  
  public init(appState: Binding<AppState>, viewModel: OnboardingViewModel) {
    _appState = appState
    self.viewModel = viewModel
  }
}
