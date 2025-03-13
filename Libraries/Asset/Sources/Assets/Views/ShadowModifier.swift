//
//  File.swift
//  Asset
//
//  Created by Abubakar Oladeji on 13/11/2024.
//

import SwiftUI

public struct ShadowViewModifier: ViewModifier {
  var color: UIColor
  var radius: CGFloat
  var x: CGFloat
  var y: CGFloat
  var spread: CGFloat
  
  public init(color: UIColor, radius: CGFloat, x: CGFloat, y: CGFloat, spread: CGFloat) {
    self.color = color
    self.radius = radius
    self.x = x
    self.y = y
    self.spread = spread
  }
  
  public func body(content: Content) -> some View {
    content
      .background(
        ShadowView(color: color, radius: radius, x: x, y: y, spread: spread)
      )
  }
}


struct ShadowView: UIViewRepresentable {
  var color: UIColor
  var radius: CGFloat
  var x: CGFloat
  var y: CGFloat
  var spread: CGFloat
  
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.layer.shadowColor = color.cgColor
    view.layer.shadowOpacity = 1
    view.layer.shadowOffset = CGSize(width: x, height: y)
    view.layer.shadowRadius = radius / 2.0
    view.layer.masksToBounds = false
    if spread == 0 {
      view.layer.shadowPath = nil
    } else {
      let dx = -spread
      let rect = view.bounds.insetBy(dx: dx, dy: dx)
      view.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    }
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
    // Update the shadow path if needed
    if spread != 0 {
      let dx = -spread
      let rect = uiView.bounds.insetBy(dx: dx, dy: dx)
      uiView.layer.shadowPath = UIBezierPath(rect: rect).cgPath
    } else {
      uiView.layer.shadowPath = nil
    }
  }
}
