//
//  CircularProgressView.swift
//  Home
//
//  Created by Abubakar Oladeji on 10/02/2025.
//

import Assets
import SwiftUI

public struct CircularProgressView: View {
  private let backgroundColor: Color
  private let progressColor: Color
  private let lineWidth: CGFloat

  private let progress: Double

  public var body: some View {
    ZStack {
      Circle()
        .stroke(backgroundColor.opacity(0.5), lineWidth: lineWidth)
        .background(Color.clear)

      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          progressColor,
          style: StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round
          )
        )
        .background(Color.clear)
        .rotationEffect(.degrees(-90))
        .animation(.easeOut, value: progress)
    }
  }

  public init(
    progress: Double,
    backgroundColor: Color = Color.EcoSort.Brand.green,
    progressColor: Color = Color.EcoSort.Brand.green,
    lineWidth: CGFloat = 5
  ) {
    self.progress = progress
    self.backgroundColor = backgroundColor
    self.progressColor = progressColor
    self.lineWidth = lineWidth
  }
}

