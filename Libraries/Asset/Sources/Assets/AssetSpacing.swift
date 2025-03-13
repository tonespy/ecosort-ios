//
//  AssetSpacing.swift
//  Asset
//
//  Created by Abubakar Oladeji on 10/11/2024.
//

import SwiftUI

public enum SpacingSize {
  case xSmall
  case small
  case medium
  case large
  case xLarge
  case custom(CGFloat)
  case multiplier(CGFloat)
  
  public var value: CGFloat {
    switch self {
    case .xSmall:
      return 4
    case .small:
      return 8
    case .medium:
      return 16
    case .large:
      return 24
    case .xLarge:
      return 32
    case .custom(let size):
      return size
    case .multiplier(let amount):
      return amount * 4
    }
  }
}

public typealias FrameSize = SpacingSize
public typealias AppPadding = SpacingSize
public typealias AppRadius = SpacingSize

public extension VStack {
  init(alignment: HorizontalAlignment = .center,
       spacing size: SpacingSize,
       @ViewBuilder content: () -> Content
  ) {
    self.init(alignment: alignment, spacing: size.value, content: content)
  }
}

//public extension HStack {
//  init(alignment: HorizontalAlignment = .center,
//       spacing size: SpacingSize,
//       @ViewBuilder content: () -> Content
//  ) {
//    self.init(alignment: alignment, spacing: size.value, content: content)
//  }
//}
