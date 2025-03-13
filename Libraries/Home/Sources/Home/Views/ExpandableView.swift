//
//  ExpandableView.swift
//  Home
//
//  Created by Abubakar Oladeji on 11/02/2025.
//

import SwiftUI

/// A generic expandable view that renders custom collapsed and expanded content.
/// - Parameters:
///   - CollapsedAction: A closure that produces the collapsed action view.
///   - ExpandedAction: A closure that produces the expanded action view.
///   - Expanded: A closure that produces the expanded view.
struct ExpandableViewMod<CollapsedAction: View, ExpandedAction: View, Expanded: View>: View {
  enum Placement { case left, right }

  /// Track whether the view is expanded.
  @Binding var isExpanded: Bool

  /// Controls which edge is considered the “open” side.
  let placement: Placement
  /// A closure to build the collapsed action view.
  let collapsedAction: () -> CollapsedAction
  /// A closure to build the expanded action view.
  let expandedAction: () -> ExpandedAction
  /// A closure to build the expanded content. It receives the current placement.
  let expandedContent: (_ placement: Placement) -> Expanded

  /// A namespace for matched geometry.
  @Namespace private var animationNamespace
  /// A shared ID for the action view (so collapsed and expanded actions animate).
  private let actionViewID = "actionView"
  /// A separate ID for the expanded content.
  private let expandedContentID = "expandedContent"

  var body: some View {
    HStack(spacing: 0) {
      if placement == .left {
        // For left placement, action view is at the left.
        Group {
          if isExpanded {
            expandedActionView
          } else {
            collapsedActionView
          }
        }
        // Expanded content appears to the right of the action view.
        if isExpanded {
          expandedContentView
        }
        Spacer(minLength: 0)
      } else {
        // For right placement, push content to the right.
        Spacer(minLength: 0)
        if isExpanded {
          expandedContentView
        }
        Group {
          if isExpanded {
            expandedActionView
          } else {
            collapsedActionView
          }
        }
      }
    }
    .animation(.spring(), value: isExpanded)
  }

  init(
    isExpanded: Binding<Bool>,
    placement: Placement,
    collapsedAction: @escaping () -> CollapsedAction,
    expandedAction: @escaping () -> ExpandedAction,
    expandedContent: @escaping (_: Placement) -> Expanded
  ) {
    _isExpanded = isExpanded
    self.placement = placement
    self.collapsedAction = collapsedAction
    self.expandedAction = expandedAction
    self.expandedContent = expandedContent
  }

  private var collapsedActionView: some View {
    collapsedAction()
      .matchedGeometryEffect(id: actionViewID, in: animationNamespace)
      .onTapGesture {
        withAnimation(.spring()) {
          isExpanded = true
        }
      }
  }

  private var expandedActionView: some View {
    expandedAction()
      .matchedGeometryEffect(id: actionViewID, in: animationNamespace)
      .onTapGesture {
        withAnimation(.spring()) {
          isExpanded = false
        }
      }
  }

  private var expandedContentView: some View {
    expandedContent(placement)
      .matchedGeometryEffect(id: expandedContentID, in: animationNamespace)
  }
}
