//
//  View+Shadow.swift
//  Asset
//
//  Created by Abubakar Oladeji on 26/01/2025.
//

import SwiftUI

public struct ShadowStyle {
  public enum Elevation: Int {
    case level0 = 0
    case level1 = 1
    case level2 = 2
    case level3 = 4
    case level4 = 8
    case level5 = 16
  }
  
  public enum Position: Int {
    case top = -1
    case center = 0
    case bottom = 1
  }
  
  public let elevation: Elevation
  public let position: Position
  
  var radius: CGFloat {
    CGFloat(elevation.rawValue * 2)
  }
  
  var offset: CGPoint {
    .init(x: 0, y: elevation.rawValue * position.rawValue)
  }
  
  var color: Color {
    elevation == .level0 ? .clear : .EcoSort.Base.black.opacity(.Ecosort.Opacity.low)
  }
  
  public static let none: Self = { .init(elevation: .level0, position: .center) }()
  public static let button: Self = { .init(elevation: .level1, position: .bottom) }()
  public static let buttonPressed: Self = { .init(elevation: .level3, position: .bottom) }()
  public static let drawer: Self = { .init(elevation: .level4, position: .center) }()
  public static let modal: Self = { .init(elevation: .level5, position: .center) }()
}

public extension View {
  /**
   Drop a shadow with a style defined in Design Standard.
   Example:
   ```
   SomeView().shadow(style: .button)
   SomeView().shadow(style: .init(elevation: .level5, position: .center))
   ```
   */
  func shadow(style: ShadowStyle) -> some View {
    shadow(
      color: style.color,
      radius: style.radius,
      x: style.offset.x,
      y: style.offset.y
    )
  }
}

struct Shadow_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 60) {
      Text("Normal Shadow")
        .frame(width: 200, height: 60)
        .background(
          Color.white.shadow(style: .button)
        )
      
      Text("Pressed Shadow")
        .frame(width: 200, height: 60)
        .background(
          Color.white.shadow(style: .buttonPressed)
        )
      
      Text("Drawer Shadow")
        .frame(width: 200, height: 60)
        .background(
          Color.white.shadow(style: .drawer)
        )
      
      Text("Modal Shadow")
        .frame(width: 200, height: 60)
        .background(
          Color.white.shadow(style: .modal)
        )
      
      Text("No Shadow")
        .frame(width: 200, height: 60)
        .background(
          Color.gray.shadow(style: .none)
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
  }
}
