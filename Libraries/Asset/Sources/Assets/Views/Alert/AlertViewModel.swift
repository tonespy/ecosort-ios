//
//  File.swift
//  Asset
//
//  Created by Abubakar Oladeji on 26/01/2025.
//

import SwiftUI

public struct AlertViewModel {
  public typealias ButtonAction = () -> Void
  
  public init(title: LocalizedStringKey,
              imageName: String? = nil,
              message: LocalizedStringKey,
              primaryButtonTitle: LocalizedStringKey? = nil,
              primaryButtonAction: ButtonAction? = nil,
              secondaryButtonTitle: LocalizedStringKey? = nil,
              secondaryButtonAction: ButtonAction? = nil,
              canDismiss: Bool = true) {
    
    self.title = title
    self.imageName = imageName
    self.message = message
    self.primaryButtonTitle = primaryButtonTitle
    self.primaryButtonAction = primaryButtonAction
    self.secondaryButtonTitle = secondaryButtonTitle
    self.secondaryButtonAction = secondaryButtonAction
    self.canDismiss = canDismiss
  }
  
  public var title: LocalizedStringKey
  public var imageName: String?
  public var message: LocalizedStringKey
  public var primaryButtonTitle: LocalizedStringKey?
  public var secondaryButtonTitle: LocalizedStringKey?
  public var primaryButtonAction: ButtonAction?
  public var secondaryButtonAction: ButtonAction?
  public var canDismiss: Bool
}
