//
//  SnackbarView.swift
//  Asset
//
//  Created by Abubakar Oladeji on 16/02/2025.
//

import SwiftUI

public struct SnackbarView: View {
  public init(
    show: Binding<Bool>,
    bgColor: Color,
    txtColor: Color,
    icon: Image? = nil,
    iconColor: Color? = nil,
    message: String
  ) {
    self._show = show
    self.bgColor = bgColor
    self.txtColor = txtColor
    self.icon = icon
    self.iconColor = iconColor
    self.message = message
  }

  @Binding public var show: Bool
  public var bgColor: Color
  public var txtColor: Color
  public var icon: Image?
  public var iconColor: Color?
  public var message: String

  // Calculate bottom padding using the key window's safe area.
  private var paddingBottom: CGFloat {
    let keyWindow = UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    return (keyWindow?.safeAreaInsets.bottom ?? 0)
  }

  // Track the vertical offset for drag gesture.
  @State private var offsetY: CGFloat = 0

  public var body: some View {
    if self.show {
      VStack {
        Spacer()
        HStack(alignment: .center, spacing: 12) {
          if let icon, let iconColor {
            icon
              .resizable()
              .foregroundColor(iconColor)
              .aspectRatio(contentMode: .fit)
              .frame(width: 14, height: 14)
          }
          Text(message)
            .foregroundColor(txtColor)
            .font(.system(size: 14))
            .frame(alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 35)
        .padding(.vertical, 8)
        .background(bgColor)
        .cornerRadius(10)
        .padding(.horizontal, 16)
        .padding(.bottom, show ? self.paddingBottom : 0)
        .offset(y: offsetY)
        .gesture(
          DragGesture()
            .onChanged { gesture in
              // Allow only downward dragging.
              if gesture.translation.height > 0 {
                offsetY = gesture.translation.height
              }
            }
            .onEnded { gesture in
              // If dragged more than 50 points, dismiss with an animation.
              if gesture.translation.height > 50 {
                withAnimation(.easeInOut) {
                  offsetY = 500  // animate off the screen
                  self.show = false
                }
              } else {
                // Otherwise, snap back to original position.
                withAnimation(.spring()) {
                  offsetY = 0
                }
              }
            }
        )
        .animation(.easeInOut, value: show)
      }
      .transition(.move(edge: .bottom))
      .ignoresSafeArea(edges: .bottom)
      .onAppear {
        // Auto-dismiss after 2 seconds if not dismissed manually.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          withAnimation(.easeInOut) {
            self.show = false
          }
        }
      }
    }
  }
}

public extension View {
  func snackbar(
    show: Binding<Bool>,
    bgColor: Color = .EcoSort.Content.primary,
    txtColor: Color = .EcoSort.Text.textO,
    icon: Image? = nil,
    iconColor: Color? = nil,
    message: String
  ) -> some View {
    self.modifier(
      SnackbarModifier(
        show: show,
        bgColor: bgColor,
        txtColor: txtColor,
        icon: icon,
        iconColor: iconColor,
        message: message
      )
    )
  }
}

struct SnackbarModifier: ViewModifier {
  @Binding var show: Bool
  var bgColor: Color
  var txtColor: Color
  var icon: Image? = nil
  var iconColor: Color? = nil
  var message: String

  func body(content: Content) -> some View {
    ZStack {
      content
      SnackbarView(
        show: $show,
        bgColor: bgColor,
        txtColor: txtColor,
        icon: icon,
        iconColor: iconColor,
        message: message
      )
    }
  }
}

