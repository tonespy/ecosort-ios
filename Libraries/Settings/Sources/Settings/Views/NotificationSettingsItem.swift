//
//  NotificationSettingsItem.swift
//  Settings
//
//  Created by Abubakar Oladeji on 02/03/2025.
//

import Assets
import Foundation
import SwiftUI

struct NotificationSettingsItem: View {
  private let settingsItem: SettingsItem
  @EnvironmentObject var settingsViewModel: SettingsViewModel

  @State private var toggleValue: Bool = false

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: .xSmall) {
        Text(LocalizedStringKey(settingsItem.identifier.title))
          .font(Font.EcoSort.body1)
          .foregroundColor(.EcoSort.Text.text5)
          .lineSpacing(AppPadding.small.value)

        Text(LocalizedStringKey(settingsItem.identifier.subtitle))
          .font(Font.EcoSort.caption1)
          .foregroundColor(.EcoSort.Text.text3)
          .lineSpacing(AppPadding.small.value)
      }

      Toggle("", isOn: $settingsViewModel.enableNotification)
        .labelsHidden()
    }
  }

  init(settingsItem: SettingsItem) {
    self.settingsItem = settingsItem
  }
}
