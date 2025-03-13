//
//  SplashScreen.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 08/02/2025.
//

import Assets
import SwiftUI
import Platform

struct SplashScreen: View {
  @EnvironmentObject private var viewModel: SplashScreenViewModel
  
  var body: some View {
    ZStack {
      if viewModel.isLoading {
        SpinnerLoadingView()
          .frame(width: 100, height: 100)
      }
    }
    .onAppear {
      viewModel.loadVersions()
    }
    .background(Color.EcoSort.Base.background)
  }
}

struct SplashScreen_Previews: PreviewProvider {
  @State static var state: AppState = .splashscreen
  static var previews: some View {
    SplashScreen()
      .environmentObject(SplashScreenViewModel(state: $state))
  }
}
