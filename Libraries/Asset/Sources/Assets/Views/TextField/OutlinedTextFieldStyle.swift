//
//  OutlinedTextFieldStyle.swift
//  Asset
//
//  Created by Abubakar Oladeji on 09/03/2025.
//

import SwiftUI

public struct OutlinedTextFieldStyle: TextFieldStyle {
  public func _body(configuration: TextField<Self._Label>) -> some View {
    configuration
      .padding()
      .overlay {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
          .stroke(Color.EcoSort.Neutral.neutral3, lineWidth: 2)
      }
  }

  public init() {}
}
