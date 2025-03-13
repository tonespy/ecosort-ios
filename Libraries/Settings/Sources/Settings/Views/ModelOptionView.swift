//
//  ModelOptionView.swift
//  Settings
//
//  Created by Abubakar Oladeji on 04/03/2025.
//

import Assets
import SwiftUI

struct ModelOptionView: View {
  let title: String
  let subtitle: String
  let selected: Bool

  var strokeColor: Color {
    selected ? .EcoSort.Button.primary : .EcoSort.Button.primaryDisabled
  } // Color.EcoSort.Neutral.neutral1
  var strokeWidth: CGFloat { selected ? 2 : 1 }

  var body: some View {
    VStack(alignment: .leading, spacing: .medium) {
      Text(LocalizedStringKey(title))
        .font(Font.EcoSort.heading)
        .foregroundColor(.EcoSort.Text.text5)
        .lineSpacing(AppPadding.small.value)

      Text(LocalizedStringKey(subtitle))
        .font(Font.EcoSort.body)
        .foregroundColor(.EcoSort.Text.text3)
        .lineSpacing(AppPadding.small.value)
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 4)
        .fill(Color.EcoSort.Base.white)
        .stroke(
          strokeColor,
          style: StrokeStyle(lineWidth: strokeWidth)
        )
        .shadow(
          color: .EcoSort.Base.border,
          radius: AppRadius.xSmall.value,
          x: 0,
          y: 3
        )
    )
  }
}

