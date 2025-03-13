//
//  ecosortApp.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 07/01/2025.
//

import Factory
import SwiftUI
import Platform
import Assets
import Onboarding

@main
struct EcosortApp: App {
  @AppStorage(UserDefaults.userOnboardingKey) var hasOnboarded: Bool = false
  @State private var appState: AppState = .splashscreen
  
  init() {
    Font.EcoSort.registerFonts()
  }
  
  var body: some Scene {
    WindowGroup {
      switch appState {
      case .splashscreen:
        SplashScreen()
          .environmentObject(SplashScreenViewModel(state: $appState))
      case .onboarding:
        OnboardingScreen(
          appState: $appState,
          viewModel: Container.shared.onboarding.resolve()
        )
      case .app:
        RootView()
      }
    }
  }
}
