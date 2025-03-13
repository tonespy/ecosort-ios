//
//  ClickableSettingsItem.swift
//  Settings
//
//  Created by Abubakar Oladeji on 02/03/2025.
//

import Foundation
import SwiftUI
import Assets

struct ClickableSettingsItem: View {
  private let settingsItem: SettingsItem

  var body: some View {
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
  }

  init(settingsItem: SettingsItem) {
    self.settingsItem = settingsItem
  }
}
