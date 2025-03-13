//
//  Fonts.swift
//
//
//  Created by Abubakar Oladeji on 25/08/2024.
//

import SwiftUI
import UIKit

/**
 UIFont.Weight.ultraLight // 100
 UIFont.Weight.thin // 200
 UIFont.Weight.light // 300
 UIFont.Weight.regular // 400
 UIFont.Weight.medium // 500
 UIFont.Weight.semibold // 600
 UIFont.Weight.bold // 700
 UIFont.Weight.heavy // 800
 UIFont.Weight.black // 900
 */

public extension Font { struct EcoSort {} }

public enum FontName: String {
  case PTBlack = "Pretendard-Black"
  
  case PTBold = "Pretendard-Bold"
  case PTExtraBold = "Pretendard-ExtraBold"
  
  case PTExtraLight = "Pretendard-ExtraLight"
  
  case PTLight = "Pretendard-Light"
  
  case PTMedium = "Pretendard-Medium"
  case PTRegular = "Pretendard-Regular"
  case PTSemiBold = "Pretendard-SemiBold"
  
  case PTThin = "Pretendard-Thin"
  
  public var title: String {
    return self.rawValue
  }
  
  public var weight: UIFont.Weight {
    switch self {
    case .PTThin:
      return .thin
    case .PTExtraLight:
      return .ultraLight
    case .PTLight:
      return .light
    case .PTRegular:
      return .regular
    case .PTMedium:
      return .medium
    case .PTSemiBold:
      return .semibold
    case .PTBold:
      return .bold
    case .PTExtraBold:
      return .heavy
    case .PTBlack:
      return .black
    }
  }
  
  public static func weight(_ identifier: UIFont.Weight) -> FontName {
    switch identifier {
    case .thin:
      return .PTThin
    case .ultraLight:
      return .PTExtraLight
    case .light:
      return .PTLight
    case .regular:
      return .PTRegular
    case .medium:
      return .PTMedium
    case .semibold:
      return .PTSemiBold
    case .bold:
      return .PTBold // 700
    case .heavy:
      return .PTExtraBold // >= 800
    case .black:
      return .PTBlack
    default:
      return .PTRegular
    }
  }
}

public extension Font.EcoSort {
  static func registerFont(_ name: String, fileExtension: String) {
    guard let fontURL = Bundle.module.url(forResource: name, withExtension: fileExtension) else {
      print("No font named \(name).\(fileExtension) was found in the module bundle")
      return
    }
    
    var error: Unmanaged<CFError>?
    CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)
    debugPrint(error ?? "Successfully registered font: \(name)")
  }
  
  static func registerFonts() {
    let fonts = [
      FontName.PTThin,
      
      FontName.PTExtraLight,
      FontName.PTLight,
      
      FontName.PTRegular,
      
      FontName.PTMedium,
      
      FontName.PTSemiBold,
      FontName.PTBold,
      FontName.PTExtraBold,
      
      FontName.PTBlack
    ]
    
    for font in fonts {
      registerFont(font.title, fileExtension: ".otf")
    }
  }
}

/**
 UIFont.Weight.ultraLight // 100
 UIFont.Weight.thin // 200
 UIFont.Weight.light // 300
 UIFont.Weight.regular // 400
 UIFont.Weight.medium // 500
 UIFont.Weight.semibold // 600
 UIFont.Weight.bold // 700
 UIFont.Weight.heavy // 800
 UIFont.Weight.black // 900

 */
public extension UIFont {
  private static func fromMetrics(_ textStyle: TextStyle, size: CGFloat, weight: Weight) -> UIFont {
    let font = FontName.weight(weight)
    let createdFont = UIFont(name: font.title, size: size)
    let fontInfo = createdFont ?? .systemFont(ofSize: size, weight: weight)
    return UIFontMetrics(forTextStyle: textStyle)
      .scaledFont(for: fontInfo)
  }
  
  // swiftlint:disable:next type_name
  class EcoSort {
    public static var largeTitle = UIFont.fromMetrics(.largeTitle, size: 34.0, weight: .semibold)
    public static var title1 = UIFont.fromMetrics(.title1, size: 28.0, weight: .semibold)
    public static var title2 = UIFont.fromMetrics(.title2, size: 22.0, weight: .semibold)
    public static var title3 = UIFont.fromMetrics(.title3, size: 20.0, weight: .semibold)
    
    public static var headline = UIFont.fromMetrics(.headline, size: 15.0, weight: .semibold)
    public static var subheadline = UIFont.fromMetrics(.subheadline, size: 13.0, weight: .semibold)
    
    public static var body1 = UIFont.fromMetrics(.body, size: 15.0, weight: .regular)
    public static var body2 = UIFont.fromMetrics(.body, size: 13.0, weight: .regular)
    public static var caption1 = UIFont.fromMetrics(.caption1, size: 12.0, weight: .regular)
    public static var caption2 = UIFont.fromMetrics(.caption2, size: 10.0, weight: .regular)
    
    public static var button1 = UIFont.fromMetrics(.title1, size: 15.0, weight: .semibold)
    public static var button2 = UIFont.fromMetrics(.title2, size: 13.0, weight: .semibold)
    
    public static var display = UIFont.fromMetrics(.headline, size: 52, weight: .bold)
    public static var displayL = UIFont.fromMetrics(.headline, size: 58, weight: .bold)
    public static var displayXL = UIFont.fromMetrics(.headline, size: 66, weight: .bold)
    
    public static var heading = UIFont.fromMetrics(.headline, size: 20, weight: .heavy)
    public static var headingS = UIFont.fromMetrics(.headline, size: 16, weight: .heavy)
    public static var headingL = UIFont.fromMetrics(.headline, size: 24, weight: .bold)
    public static var headingXL = UIFont.fromMetrics(.headline, size: 29, weight: .bold)
    
    public static var body = UIFont.fromMetrics(.body, size: 16, weight: .regular)
    public static var bodyS = UIFont.fromMetrics(.body, size: 13, weight: .regular)
    public static var bodyL = UIFont.fromMetrics(.body, size: 24, weight: .regular)
  }
}

public extension Font.EcoSort {
  static var largeTitle: Font { .custom(FontName.PTSemiBold.title, size: 34, relativeTo: .largeTitle) }
  static var title1: Font { .custom(FontName.PTSemiBold.title, size: 28, relativeTo: .title) }
  static var title2: Font { .custom(FontName.PTSemiBold.title, size: 22, relativeTo: .title2) }
  static var title3: Font { .custom(FontName.PTSemiBold.title, size: 20, relativeTo: .title3) }
  
  static var headline: Font { .custom(FontName.PTSemiBold.title, size: 15, relativeTo: .headline) }
  static var subheadline: Font { .custom(FontName.PTSemiBold.title, size: 13, relativeTo: .subheadline) }
  
  static var body1: Font { .custom(FontName.PTRegular.title, size: 15, relativeTo: .body) }
  static var body2: Font { .custom(FontName.PTRegular.title, size: 13, relativeTo: .body) }
  static var caption1: Font { .custom(FontName.PTRegular.title, size: 12, relativeTo: .caption) }
  static var caption2: Font { .custom(FontName.PTRegular.title, size: 10, relativeTo: .caption2) }
  
  static var button1: Font { .custom(FontName.PTSemiBold.title, size: 15, relativeTo: .title) }
  static var button2: Font { .custom(FontName.PTSemiBold.title, size: 13, relativeTo: .title2) }
  
  static var display: Font { .custom(FontName.PTBold.title, size: 52, relativeTo: .headline) }
  static var displayL: Font { .custom(FontName.PTBold.title, size: 58, relativeTo: .headline) }
  static var displayXL: Font { .custom(FontName.PTBold.title, size: 66, relativeTo: .headline) }
  
  static var heading: Font { .custom(FontName.PTExtraBold.title, size: 20, relativeTo: .headline) }
  static var headingS: Font { .custom(FontName.PTExtraBold.title, size: 16, relativeTo: .headline) }
  static var headingL: Font { .custom(FontName.PTBold.title, size: 24, relativeTo: .headline) }
  static var headingXL: Font { .custom(FontName.PTBold.title, size: 29, relativeTo: .headline) }
  
  static var body: Font { .custom(FontName.PTRegular.title, size: 16, relativeTo: .body) }
  static var bodyS: Font { .custom(FontName.PTRegular.title, size: 13, relativeTo: .body) }
  static var bodyL: Font { .custom(FontName.PTRegular.title, size: 24, relativeTo: .body) }
}
