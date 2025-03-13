//
//  ButtonView+Style.swift
//  Asset
//
//  Created by Abubakar Oladeji on 26/01/2025.
//

import SwiftUI

public struct PrimaryButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .modifier(
        RoundedButtonStyleModifier(
          background: Color.EcoSort.Button.primary,
          foreground: Color.EcoSort.Text.textO
        )
      )
      .isPressed(configuration)
  }
}

public struct PrimaryCapsuleButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .modifier(
        CapsuleButtonStyleModifier(
          background: Color.EcoSort.Button.primary,
          foreground: Color.EcoSort.Text.textO
        )
      )
      .isPressed(configuration)
  }
}

public struct SecondaryButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .modifier(
        RoundedButtonStyleModifier(
          background: Color.EcoSort.Button.secondary,
          foreground: Color.EcoSort.Text.text1
        )
      )
      .isPressed(configuration)
  }
}

public struct SecondaryCapsuleButtonStyle: ButtonStyle {
  
  public init() {}
  
  public func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      .modifier(
        CapsuleButtonStyleModifier(
          background: Color.EcoSort.Button.secondary,
          foreground: Color.EcoSort.Text.text1
        )
      )
      .isPressed(configuration)
  }
}

private struct RoundedButtonStyleModifier: ViewModifier {
  
  let background: Color
  
  let foreground: Color
  
  // tracks if the button is enabled or not
  @Environment(\.isEnabled) var isEnabled
  // tracks the pressed state
  
  func body(content: Content) -> some View {
    return content
      .modifier(CommonButtonModifier())
      .background(isEnabled ? background : Color.EcoSort.Button.primaryDisabled)
      .foregroundColor(isEnabled ? foreground : Color.EcoSort.Base.border)
      .cornerRadius(5)
//      .shadow(radius: 15)
  }
}

private struct CapsuleButtonStyleModifier: ViewModifier {
  
  let background: Color
  
  let foreground: Color
  
  // tracks if the button is enabled or not
  @Environment(\.isEnabled) var isEnabled
  
  func body(content: Content) -> some View {
    content
      .modifier(CommonButtonModifier())
      .background(
        RoundedRectangle(cornerRadius: SpacingSize.small.value)
          .fill(isEnabled ? background : Color.EcoSort.Button.primaryPressed)
      )
      .foregroundColor(isEnabled ? foreground : Color.EcoSort.Base.border)
//      .shadow(radius: 5)
  }
}

private struct CommonButtonModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.EcoSort.button1)
      .lineLimit(1)
      .frame(maxWidth: .infinity)
      .padding(14)
  }
}

private extension View {
  func isPressed(_ configuration: ButtonStyleConfiguration) -> some View {
    self
      .opacity(configuration.isPressed ? 0.8 : 1.0)
      .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
  }
}
