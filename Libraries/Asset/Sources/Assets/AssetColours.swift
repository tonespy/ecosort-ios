import SwiftUI

public extension Color { struct EcoSort {} }

public extension Color.EcoSort {
  struct Scrim {
    public static let scrim = Color("scrim", bundle: .sharedResources)
  }
}

public extension Color {
  var uiColor: UIColor? {
    if #available(iOS 14.0, *) {
      return UIColor(self)
    } else {
      let scanner = Scanner(string: self.description.trimmingCharacters(in: CharacterSet.alphanumerics.inverted))
      var hexNumber: UInt64 = 0
      var r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 0.0
      let result = scanner.scanHexInt64(&hexNumber)
      if result {
        r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
        g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
        b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
        a = CGFloat(hexNumber & 0x000000ff) / 255
        return UIColor(red: r, green: g, blue: b, alpha: a)
      } else {
        return nil
      }
    }
  }
}

public extension Color {
  func getColorForTrait(_ trait: UIUserInterfaceStyle) -> Color {
    let newColor = self.uiColor?.resolvedColor(with: UITraitCollection(
      userInterfaceStyle: trait
    ))
    
    guard let newColor else { return self }
    return Color(newColor)
  }
}

public extension Color.EcoSort {
  struct Base {
    public static let background = Color("baseBackground", bundle: .sharedResources)
    public static let black = Color("baseBlack", bundle: .sharedResources)
    public static let white = Color("baseWhite", bundle: .sharedResources)
    public static let border = Color("baseBorder", bundle: .sharedResources)
    public static let imageBg = Color("baseImagebg", bundle: .sharedResources)
  }
}

public extension Color.EcoSort {
  struct Brand {
    public static let blue = Color("brandBlue", bundle: .sharedResources)
    public static let blueInverse = Color("brandBlueInverse", bundle: .sharedResources)
    public static let brick = Color("brandBrick", bundle: .sharedResources)
    public static let brickInverse = Color("brandBrickInverse", bundle: .sharedResources)
    public static let burgundy = Color("brandBurgundy", bundle: .sharedResources)
    public static let burgundyInverse = Color("brandBurgundyInverse", bundle: .sharedResources)
    public static let green = Color("brandGreen", bundle: .sharedResources)
    public static let greenInverse = Color("brandGreenInverse", bundle: .sharedResources)
    public static let violet = Color("brandViolet", bundle: .sharedResources)
    public static let violetInverse = Color("brandVioletInverse", bundle: .sharedResources)
  }
}

public extension Color.EcoSort {
  struct Button {
    public static let primary = Color("buttonPrimary", bundle: .sharedResources)
    public static let primaryDisabled = Color("buttonPrimaryDisabled", bundle: .sharedResources)
    public static let primaryHover = Color("buttonPrimaryHover", bundle: .sharedResources)
    public static let primaryPressed = Color("buttonPrimaryPressed", bundle: .sharedResources)
    
    public static let secondary = Color("buttonPrimary", bundle: .sharedResources)
    public static let secondaryDisabled = Color("buttonSecondaryDisabled", bundle: .sharedResources)
    public static let secondaryHover = Color("buttonSecondaryHover", bundle: .sharedResources)
    public static let secondaryPressed = Color("buttonSecondaryPressed", bundle: .sharedResources)
  }
}

public extension Color.EcoSort {
  struct Content {
    public static let disabled = Color("contentDisabled", bundle: .sharedResources)
    
    public static let negative = Color("contentNegative", bundle: .sharedResources)
    public static let negativeDark = Color("contentNegativeDark", bundle: .sharedResources)
    public static let negativeLight = Color("contentNegativeLight", bundle: .sharedResources)
    
    public static let postive = Color("contentPositive", bundle: .sharedResources)
    public static let positiveLight = Color("contentPositiveLight", bundle: .sharedResources)
    public static let positiveDark = Color("contentPositiveDark", bundle: .sharedResources)
    
    public static let primary = Color("contentPrimary", bundle: .sharedResources)
    public static let secondary = Color("contentSecondary", bundle: .sharedResources)
    public static let tertiary = Color("contentTertiary", bundle: .sharedResources)
    
    public static let warning = Color("contentWarning", bundle: .sharedResources)
    public static let warningDark = Color("contentWarningDark", bundle: .sharedResources)
    public static let warningLight = Color("contentWarningLight", bundle: .sharedResources)
  }
}

public extension Color.EcoSort {
  struct Neutral {
    public static let neutral0 = Color("Neutral-0", bundle: .sharedResources)
    public static let neutral1 = Color("Neutral-1", bundle: .sharedResources)
    public static let neutral2 = Color("Neutral-2", bundle: .sharedResources)
    public static let neutral3 = Color("Neutral-3", bundle: .sharedResources)
    public static let neutral4 = Color("Neutral-4", bundle: .sharedResources)
    public static let neutral5 = Color("Neutral-5", bundle: .sharedResources)
    public static let neutral6 = Color("Neutral-6", bundle: .sharedResources)
    public static let neutral7 = Color("Neutral-7", bundle: .sharedResources)
  }
}

public extension Color.EcoSort {
  struct Text {
    public static let textO = Color("Text-0", bundle: .sharedResources)
    public static let text1 = Color("Text-1", bundle: .sharedResources)
    public static let text2 = Color("Text-2", bundle: .sharedResources)
    public static let text3 = Color("Text-3", bundle: .sharedResources)
    public static let text4 = Color("Text-4", bundle: .sharedResources)
    public static let text5 = Color("Text-5", bundle: .sharedResources)
    public static let text6 = Color("Text-6", bundle: .sharedResources)
  }
}
