//
//  CardView.swift
//  Home
//
//  Created by Abubakar Oladeji on 24/03/2025.
//

import SwiftUI

// Implementation gotten from:
// https://medium.com/@jaredcassoutt/creating-tinder-like-swipeable-cards-in-swiftui-193fab1427b8
struct NewCardView: View {
  var model: PredictionSessionMedia
  var dragOffset: CGSize
  var isTopCard: Bool
  var isSecondCard: Bool

  var image: UIImage {
    UIImage(data: model.data)!
  }

  var body: some View {
    VStack {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(width: 300, height: 400)
        .clipped()
        .background(Color.white)

      HStack {
        Text("Prediction: ")
          .font(Font.EcoSort.heading)
          .foregroundColor(.EcoSort.Text.text5)

        Text(model.predictedClass?.displayName ?? "Unknown")
          .font(Font.EcoSort.body)
          .foregroundColor(.EcoSort.Text.text3)
      }
    }
    .background(Color.EcoSort.Base.background)
    .cornerRadius(15)
    .shadow(color: isTopCard ? getShadowColor() : (isSecondCard && dragOffset.width != 0 ? Color.gray.opacity(0.2) : Color.clear), radius: 10, x: 0, y: 3)
    .foregroundColor(.black)
  }

  private func getShadowColor() -> Color {
    if dragOffset.width > 0 {
      return Color.green.opacity(0.5)
    } else if dragOffset.width < 0 {
      return Color.red.opacity(0.5)
    } else {
      return Color.gray.opacity(0.2)
    }
  }
}
