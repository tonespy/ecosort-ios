//
//  File.swift
//  Asset
//
//  Created by Abubakar Oladeji on 26/01/2025.
//

import Foundation

public extension Double {
  // swiftlint:disable:next type_name
  struct Ecosort {
    /// Transparency usually for background color
    public struct Opacity {
      /// Opacity of 25% which is nearly transparent.
      public static let low: Double = 0.25
      /// Opacity of 50%.
      public static let half: Double = 0.5
      /// Opacity of 75% which is nearly opaque.
      public static let high: Double = 0.75
    }
    
    public struct AnimationDuration {
      public static let short: Double = 0.15
      public static let medium: Double = 0.3
      public static let long: Double = 0.5
    }
  }
}
