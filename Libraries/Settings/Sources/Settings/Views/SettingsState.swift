//
//  SettingsState.swift
//  Settings
//
//  Created by Abubakar Oladeji on 23/02/2025.
//

import Combine

public final class SettingsState: ObservableObject {
  @Published public var didSelectClose = false
  public init() {}
}
