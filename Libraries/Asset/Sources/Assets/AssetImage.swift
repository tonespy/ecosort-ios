import SwiftUI

public extension Image { struct EcoSort {} }

public extension Image.EcoSort {
  
  struct Onboarding {
    public static let ecosortIcon = Image("icon.onboarding.badge", bundle: .sharedResources)
  }
  
  struct Loading {
    public static let bottle = Image("icon.loading.bottle", bundle: .sharedResources)
    public static let glass = Image("icon.loading.glass", bundle: .sharedResources)
    public static let paper = Image("icon.loading.paper", bundle: .sharedResources)
    public static let plastic = Image("icon.loading.plastic", bundle: .sharedResources)
    public static let sock = Image("icon.loading.sock", bundle: .sharedResources)
    public static let trash = Image("icon.loading.trash", bundle: .sharedResources)
  }

  struct Home {
    public static let scanIcon = Image("icon.home.scan", bundle: .sharedResources)
    public static let emptyRecordIcon = Image(
      "icon.home.emptypage",
      bundle: .sharedResources
    )
  }
}
