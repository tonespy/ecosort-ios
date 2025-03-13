//
//  ContentView.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 07/01/2025.
//

import Factory
import Home
import SwiftUI
import Settings

struct RootView: View {
  @StateObject private var appCoordinator: AppCoordinator = .init()
  @State private var showSettings: Bool = false

  var body: some View {
    ZStack {
      HomeScreen(viewModel: Container.shared.homwViewModel.resolve())
        .environmentObject(appCoordinator.homeState)
    }
    .onReceive(appCoordinator.$settingsState) {
      showSettings = $0 != nil
    }
    .sheet(isPresented: $showSettings) {
      appCoordinator.settingsState?.didSelectClose.toggle()
    } content: {
      appCoordinator.settingsState.map {
        SettingsScreen(
          viewModel: Container.shared.settingsViewModel.resolve()
        )
        .environmentObject($0)
      }
    }
  }
}
