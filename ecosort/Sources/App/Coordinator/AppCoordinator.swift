//
//  AppCoordinator.swift
//  ecosort
//
//  Created by Abubakar Oladeji on 23/02/2025.
//

import Combine
import Home
import Settings
import SwiftUI

final class AppCoordinator: ObservableObject {
  @Published var homeState: HomeState = .init()
  @Published var settingsState: SettingsState?

  private var cancellables = Set<AnyCancellable>()

  init() {
    // Create a publisher that triggers when homeState.didSelectSettings becomes true,
    // then creates a new SettingsState.
    let ecoStartSettingsPublisher = $homeState
      .flatMap { homeState in
        homeState.$didSelectSettings
          .compactMap { didSelect -> SettingsState? in
            didSelect == true ? SettingsState() : nil
          }
      }
      .share()

    // When a new SettingsState is created, assign it to settingsState.
    ecoStartSettingsPublisher
      .map { Optional.some($0) }
      .assign(to: \.settingsState, on: self)
      .store(in: &cancellables)

    // When the SettingsState’s didSelectClose becomes true, set settingsState to nil.
    ecoStartSettingsPublisher
      .flatMap { settings in
        settings.$didSelectClose
      }
      .filter { $0 }
      .handleEvents(receiveOutput: { _ in
        self.homeState.didSelectSettings = false
      })
      .map { _ in nil }
      .assign(to: \.settingsState, on: self)
      .store(in: &cancellables)
  }
}
