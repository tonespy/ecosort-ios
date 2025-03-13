//
//  InformationView.swift
//  Onboarding
//
//  Created by Abubakar Oladeji on 14/01/2025.
//

import SwiftUI
import Assets

struct InformationView: View {
  @EnvironmentObject var viewModel: OnboardingViewModel
  
  public init() {}
  
  var body: some View {
    VStack(alignment: .leading, spacing: .multiplier(0)) {
      VStack(alignment: .center) {
        Image.EcoSort.Onboarding.ecosortIcon
          .resizable()
          .scaledToFill()
          .frame(width: 150, height: 150)
          .frame(alignment: .center)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      
      VStack(alignment: .leading, spacing: .xLarge) {
        Spacer()
        texts
        
        Button(action: { viewModel.next() }) {
          Text("Get started")
            .font(Font.EcoSort.body)
            .foregroundColor(.EcoSort.Text.textO)
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(
              RoundedRectangle(cornerRadius: SpacingSize.small.value)
                .fill(Color.EcoSort.Button.primary)
            )
        }
      }
      .padding(16)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
  
  private var texts: some View {
    VStack(alignment: .leading, spacing: .medium) {
      Spacer()
      Text("onboarding_info_title")
        .font(Font.EcoSort.headingXL)
        .foregroundStyle(Color.EcoSort.Text.text5)
        .lineSpacing(11)
      
      Text("Easily identify waste categories with AI and contribute to a cleaner, greener world.")
        .font(Font.EcoSort.body)
        .foregroundStyle(Color.EcoSort.Text.text4)
        .lineSpacing(8)
    }
  }
}
