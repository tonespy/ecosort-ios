//
//  EmptyHomeView.swift
//  Home
//
//  Created by Abubakar Oladeji on 20/03/2025.
//

import Assets
import SwiftUI

struct EmptyHomeView: View {
  @EnvironmentObject var homeViewModel: HomeViewModel

  var body: some View {
    VStack(alignment: .center, spacing: .medium) {
      Image
        .EcoSort
        .Home
        .emptyRecordIcon
        .resizable()
        .frame(width: 200, height: 200)
      
      Text("No records found")
        .font(.EcoSort.headline)
        .foregroundStyle(Color.EcoSort.Text.text4)

      Button(action: {
        homeViewModel.showMediaPicker = true
      }) {
        Text("Scan a new record")
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
  }
}
