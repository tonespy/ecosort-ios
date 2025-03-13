//
//  File.swift
//  Asset
//
//  Created by Abubakar Oladeji on 13/11/2024.
//

import SwiftUI

@available(iOS 16.0, *)
public struct LayoutVHStack: Layout {
  public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    // Determine the required size
    let horizontalSizes = subviews.map { $0.sizeThatFits(.unspecified) }
    let totalWidth = horizontalSizes.reduce(0) { $0 + $1.width }
    
    if totalWidth <= (proposal.width ?? .infinity) {
      // Use HStack-like layout
      let maxHeight = horizontalSizes.map { $0.height }.max() ?? 0
      return CGSize(width: totalWidth, height: maxHeight)
    } else {
      // Use VStack-like layout
      let totalHeight = horizontalSizes.map { $0.height }.reduce(0, +)
      let maxWidth = horizontalSizes.map { $0.width }.max() ?? 0
      return CGSize(width: maxWidth, height: totalHeight)
    }
  }
  
  public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    let horizontalSizes = subviews.map { $0.sizeThatFits(.unspecified) }
    let totalWidth = horizontalSizes.reduce(0) { $0 + $1.width }
    
    if totalWidth <= bounds.width {
      // Place subviews horizontally
      var xOffset = bounds.minX
      for (index, subview) in subviews.enumerated() {
        let size = horizontalSizes[index]
        let yOffset = bounds.midY - size.height / 2
        subview.place(at: CGPoint(x: xOffset, y: yOffset), proposal: ProposedViewSize(size))
        xOffset += size.width
      }
    } else {
      // Place subviews vertically
      var yOffset = bounds.minY
      for (index, subview) in subviews.enumerated() {
        let size = horizontalSizes[index]
        let xOffset = bounds.midX - size.width / 2
        subview.place(at: CGPoint(x: xOffset, y: yOffset), proposal: ProposedViewSize(size))
        yOffset += size.height
      }
    }
  }
}

public struct AdaptiveVHStack<Content: View>: View {
  @Environment(\.sizeCategory) var sizeCategory
  let alignment: Alignment
  let spacing: CGFloat?
  let content: () -> Content
  
  public init(
    alignment: Alignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: @escaping () -> Content
  ) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content
  }
  
  public var body: some View {
    if shouldUseVStack {
      VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
    } else {
      HStack(alignment: verticalAlignment, spacing: spacing, content: content)
    }
  }
  
  var shouldUseVStack: Bool {
    // Default logic based on sizeCategory
    AdaptiveVHStack.defaultShouldUseVStack(sizeCategory: sizeCategory)
  }
  
  var horizontalAlignment: HorizontalAlignment {
    switch alignment {
    case .leading, .topLeading, .bottomLeading:
      return .leading
    case .trailing, .topTrailing, .bottomTrailing:
      return .trailing
    default:
      return .center
    }
  }
  
  var verticalAlignment: VerticalAlignment {
    switch alignment {
    case .top, .topLeading, .topTrailing:
      return .top
    case .bottom, .bottomLeading, .bottomTrailing:
      return .bottom
    default:
      return .center
    }
  }
  
  private static func defaultShouldUseVStack(sizeCategory: ContentSizeCategory) -> Bool {
    // Define when to switch to VStack
    switch sizeCategory {
    case .extraExtraLarge, .extraExtraExtraLarge, .accessibilityMedium,
        .accessibilityLarge, .accessibilityExtraLarge,
        .accessibilityExtraExtraLarge, .accessibilityExtraExtraExtraLarge:
      return true
    default:
      return false
    }
  }
}

public struct VHStack<Content: View>: View {
  private let alignment: Alignment
  private let spacing: CGFloat?
  private let content: () -> Content
  
  public init(alignment: Alignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
    self.alignment = alignment
    self.spacing = spacing
    self.content = content
  }
  
  public var body: some View {
    if #available(iOS 16.0, *) {
      LayoutVHStack { content() }
    } else {
      AdaptiveVHStack(alignment: alignment, spacing: spacing, content: content)
    }
  }
}

