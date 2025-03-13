#!/usr/bin/env swift
//
//  Prebuild.swift
//
//
//  Created by Abubakar Oladeji on 18/07/2024.
//

import Foundation

let colorsLight: [String: [String: String]] = [
  "brand": [
    "brandPrimary": "#233161",
    "brandPrimaryHover": "#27366b",
    "brandPrimaryActive": "#202c57",
    "textOnBrandPrimary": "#FFFFFF",
    "brandSecondary": "#FFD858",
    "brandSecondaryHover": "#ffee61",
    "brandSecondaryActive": "#e6c24f",
    "textOnBrandSecondary": "#000000",
    "borderBrandPrimary": "#233161",
    "textBrandOnSurface": "#233161",
    "textBrandOnElevated": "#354a92"
  ],
  "common": [
    // NEUTRAL
    
    "neutralPrimary": "#1A2329", // neutral13
    "neutralPrimaryHover": "#2B343A", // neutral21
    "neutralPrimaryActive": "#141D23", // neutral10
    "textOnNeutralPrimary": "#FFFFFF", // neutral100
    
    "neutralSecondary": "#F8FAFB", // neutral98
    "neutralSecondaryHover": "#EFF1F2", // neutral95
    "neutralSecondaryActive": "#DFE3E5", // neutral90
    "textOnNeutralSecondary": "#091218", // neutral5
    
    "borderNeutralPrimary": "#B1BAC2", // neutral75
    
    // ERROR
    
    "errorPrimary": "#D81819", // error46
    "errorPrimaryHover": "#FF3E34", // error57
    "errorPrimaryActive": "#AE000A", // error36
    "textOnErrorPrimary": "#FFFFFF", // error100
    
    "errorSecondary": "#FFE9E6", // error94
    "errorSecondaryHover": "#FFDAD5", // error90
    "errorSecondaryActive": "#FFCFC8", // error87
    "textOnErrorSecondary": "#D81819", // error46
    
    "borderErrorPrimary": "#D81819", // error46
    
    "textErrorOnSurface": "#D81819", // error46
    
    // DISABLED
    
    "disabled": "#DFE3E5", // neutral90
    "textOnDisabled": "#B1BAC2", // neutral75
    
    "borderDisabled": "#B1BAC2", // neutral75
    
    "textDisabledOnSurface": "#B1BAC2", // neutral75
    
    // ACCENT
    
    "accentPrimary": "#FF6F61", // fuchsia50
    "textOnAccentPrimary": "#FFFFFF", // fuc
    
    "accentSecondary": "#FFE8EC", // fuchsia94
    "textOnAccentSecondary": "#C30063", // fuchsia42
    
    "borderAccentPrimary": "#FF5733", // fuchsia64
    
    "textAccentOnSurface": "#C70039", // fuchsia42
    
    // SUCCESS
    
    "successPrimary": "#00A645", // success60
    "textOnSuccessPrimary": "#FFFFFF", // success100
    
    "successSecondary": "#EBFFE7", // success98
    "textOnSuccessSecondary": "#006E2B", // success40
    
    "borderSuccessPrimary": "#39C35E", // success70
    
    "textSuccessOnSurface": "#006E2B", // success40
    
    // WARNING
    
    "warningPrimary": "#F2B824", // warning78
    "textOnWarningPrimary": "#5C4300", // warning30
    
    "warningSecondary": "#FFECCA", // warning94
    "textOnWarningSecondary": "#5C4300", // warning30
    
    "borderWarningPrimary": "#F2B824", // warning78
    
    // INFO
    
    "infoPrimary": "#0075C4", // info48
    "textOnInfoPrimary": "#FFFFFF", // info100
    
    "infoSecondary": "#E0ECFF", // info93
    "textOnInfoSecondary": "#000F20", // info4
    
    "borderInfoPrimary": "#8EC2FF", // info77
    
    "textInfoOnSurface": "#0075C4", // info48
    
    // SURFACE
    
    "surfacePrimary": "#FFFFFF", // neutral100
    "surfaceSecondary": "#F5F7F8", // neutral97
    
    "textPrimaryOnSurface": "#091218", // neutral5
    "textSecondaryOnSurface": "#606970", // neutral44
    
    // LINK
    
    "textLinkOnSurface": "#233161", // indigo33
    "textLinkHoverOnSurface": "#3E008E", // indigo20
    "textLinkActiveOnSurface": "#835CCD", // indigo48
    "textLinkVisitedOnSurface": "#27366b", // indigo36
    
    // BORDER
    
    "borderPrimary": "#141D23", // neutral13
    "borderSecondary": "#B1BAC2", // neutral75
    
    // ELEVATED
    
    "elevated": "#2F343B", // neutral10
    "textPrimaryOnElevated": "#FFFFFF", // neutral100
    "textSecondaryOnElevated": "#B1BAC2", // neutral75
    
    // SCRIM
    
    "scrim": "#00000060"
  ],
  "static": [
    "staticNormal": "#FFFFFF", // neutral100
    "staticBorder": "#FFFFFF", // neutral100
    "staticTextPrimary": "#091218", // neutral5
  ]
]

let colorsDark: [String: [String: String]] = [
  "brand": [
    "brandPrimary": "#27366b",
    "brandPrimaryHover": "#2b3b76",
    "brandPrimaryActive": "#233160",
    "textOnBrandPrimary": "#FFFFFF",
    "brandSecondary": "#162a5c",
    "brandSecondaryHover": "#1e004c",
    "brandSecondaryActive": "#18003e",
    "textOnBrandSecondary": "#FFFFFF",
    "borderBrandPrimary": "#27366b",
    "textBrandOnSurface": "#27366b",
    "textBrandOnElevated": "#3b51a0"
  ],
  "common": [
    // NEUTRAL
    
    "neutralPrimary": "#2B343A", // neutral21
    "neutralPrimaryHover": "#606970", // neutral44
    "neutralPrimaryActive": "#02080E", // neutral2
    "textOnNeutralPrimary": "#FFFFFF", // neutral100
    
    "neutralSecondary": "#141D23", // neutral10
    "neutralSecondaryHover": "#2B343A", // neutral21
    "neutralSecondaryActive": "#040C12", // neutral2
    "textOnNeutralSecondary": "#FFFFFF", // neutral100
    
    "borderNeutralPrimary": "#2B343A", // neutral21
    
    // ERROR
    
    "errorPrimary": "#D91A1A", // error46
    "errorPrimaryHover": "#FF3E34", // error57
    "errorPrimaryActive": "#9F2B18", // error36
    "textOnErrorPrimary": "#FFFFFF", // error100
    
    "errorSecondary": "#360001", // error7
    "errorSecondaryHover": "#2D0001", // error5
    "errorSecondaryActive": "#280000", // error4
    "textOnErrorSecondary": "#FF3E34", // error57
    
    "borderErrorPrimary": "#FF3E34", // error57
    
    "textErrorOnSurface": "#FF3E34", // error57
    
    // DISABLED
    
    "disabled": "#2B343A", // neutral21
    "textOnDisabled": "#606970", // neutral44
    
    "borderDisabled": "#2B343A", // neutral21
    
    "textDisabledOnSurface": "#2B343A", // neutral21
    
    // ACCENT
    
    "accentPrimary": "#FF6347", // fuchsia42
    "textOnAccentPrimary": "#FFFFFF", // fuchsia100
    
    "accentSecondary": "#550028", // fuchsia16
    "textOnAccentSecondary": "#FFB9CB", // fuchsia82
    
    "borderAccentPrimary": "#FF4500", // fuchsia50
    
    "textAccentOnSurface": "#900C3F", // fuchsia54
    
    // SUCCESS
    
    "successPrimary": "#00531E", // success30
    "textOnSuccessPrimary": "#FFFFFF", // success100
    
    "successSecondary": "#00320F", // success17
    "textOnSuccessSecondary": "#EBFFE7", // success98
    
    "borderSuccessPrimary": "#04A746", // success60
    
    "textSuccessOnSurface": "#04A746", // success60
    
    // WARNING
    
    "warningPrimary": "#F2B824", // warning78
    "textOnWarningPrimary": "#5C4300", // warning30
    
    "warningSecondary": "#6A4E00", // warning35
    "textOnWarningSecondary": "#FFCA52", // warning84
    
    "borderWarningPrimary": "#956E00", // warning49
    
    // INFO
    
    "infoPrimary": "#00528C", // info34
    "textOnInfoPrimary": "#FFFFFF", // info100
    
    "infoSecondary": "#001930", // info8
    "textOnInfoSecondary": "#E0ECFF", // info93
    
    "borderInfoPrimary": "#003B67", // info24
    
    "textInfoOnSurface": "#228FE8", // info58
    
    // SURFACE
    
    "surfacePrimary": "#0C141A", // neutral6
    "surfaceSecondary": "#02080E", // neutral2
    
    "textPrimaryOnSurface": "#FFFFFF", // neutral100
    "textSecondaryOnSurface": "#B1BAC2", // neutral75
    
    // LINK
    
    "textLinkOnSurface": "#354a92", // indigo55
    "textLinkHoverOnSurface": "#D5BAFF", // indigo80
    "textLinkActiveOnSurface": "#233161", // indigo33
    "textLinkVisitedOnSurface": "#D5BAFF", // indigo80
    
    // BORDER
    "borderPrimary": "#868F97", // neutral59
    "borderSecondary": "#2B343A", // neutral21
    
    // ELEVATED
    
    "elevated": "#1A2329", // neutral13
    "textPrimaryOnElevated": "#FFFFFF", // neutral100
    "textSecondaryOnElevated": "#EEEEEE",
    
    // SCRIM
    "scrim": "#00000060"
  ],
  "static": [
    "staticNormal": "#000000", // neutral0
    "staticBorder": "#000000", // neutral0
    "staticTextPrimary": "#FFFFFF", // neutral100
  ]
]

let colorGroups: [String: [String]] = [
  "accent": [
    "accentPrimary",
    "textOnAccentPrimary",
    "accentSecondary",
    "textOnAccentSecondary",
    "borderAccentPrimary",
    "textAccentOnSurface"
  ],
  "border": [
    "borderPrimary",
    "borderSecondary"
  ],
  "brand": [
    "brandPrimary",
    "brandPrimaryHover",
    "brandPrimaryActive",
    "textOnBrandPrimary",
    "brandSecondary",
    "brandSecondaryHover",
    "brandSecondaryActive",
    "textOnBrandSecondary",
    "borderBrandPrimary",
    "textBrandOnSurface",
    "textBrandOnElevated"
  ],
  "disabled": [
    "disabled",
    "textOnDisabled",
    "borderDisabled",
    "textDisabledOnSurface"
  ],
  "elevated": [
    "elevated"
  ],
  "error": [
    "errorPrimary",
    "errorPrimaryHover",
    "errorPrimaryActive",
    "textOnErrorPrimary",
    "errorSecondary",
    "errorSecondaryHover",
    "errorSecondaryActive",
    "textOnErrorSecondary",
    "borderErrorPrimary",
    "textErrorOnSurface"
  ],
  "info": [
    "infoPrimary",
    "textOnInfoPrimary",
    "infoSecondary",
    "textOnInfoSecondary",
    "borderInfoPrimary",
    "textInfoOnSurface"
  ],
  "link": [
    "textLinkOnSurface",
    "textLinkActiveOnSurface",
    "textLinkHoverOnSurface",
    "textLinkVisitedOnSurface"
  ],
  "neutral": [
    "neutralPrimary",
    "neutralPrimaryHover",
    "neutralPrimaryActive",
    "textOnNeutralPrimary",
    "neutralSecondary",
    "neutralSecondaryHover",
    "neutralSecondaryActive",
    "textOnNeutralSecondary",
    "borderNeutralPrimary"
  ],
  "scrim": [
    "scrim" // Translucent background behind modals.
  ],
  "static": [
    "staticNormal",
    "staticBorder",
    "staticTextPrimary"
  ],
  "success": [
    "successPrimary",
    "textOnSuccessPrimary",
    "successSecondary",
    "textOnSuccessSecondary",
    "textSuccessOnSurface",
    "borderSuccessPrimary"
  ],
  "surface": [
    "surfacePrimary",
    "surfaceSecondary"
  ],
  "text": [
    "textPrimaryOnSurface",
    "textSecondaryOnSurface",
    "textDisabledOnSurface",
    "textPrimaryOnElevated",
    "textSecondaryOnElevated"
  ],
  "warning": [
    "warningPrimary",
    "textOnWarningPrimary",
    "warningSecondary",
    "textOnWarningSecondary",
    "borderWarningPrimary"
  ]
]

func createColorComponents(color: String) -> [String: String] {
  let red = Double(Int(color.prefix(3).suffix(2), radix: 16)!) / 255.0
  let green = Double(Int(color.prefix(5).suffix(2), radix: 16)!) / 255.0
  let blue = Double(Int(color.suffix(2), radix: 16)!) / 255.0
  return [
    "red": String(format: "%.3f", red),
    "green": String(format: "%.3f", green),
    "blue": String(format: "%.3f", blue),
    "alpha": "1.000"
  ]
}

func createColorJSON(lightColor: String, darkColor: String) -> [String: Any] {
  return [
    "info": [
      "version": 1,
      "author": "xcode"
    ],
    "colors": [
      [
        "idiom": "universal",
        "appearances": [
          [
            "appearance": "luminosity",
            "value": "light"
          ]
        ],
        "color": [
          "color-space": "srgb",
          "components": createColorComponents(color: lightColor)
        ]
      ],
      [
        "idiom": "universal",
        "appearances": [
          [
            "appearance": "luminosity",
            "value": "dark"
          ]
        ],
        "color": [
          "color-space": "srgb",
          "components": createColorComponents(color: darkColor)
        ]
      ]
    ]
  ]
}

func createXCAssets(colorsLight: [String: [String: String]], colorsDark: [String: [String: String]]) -> ReturnCode {
  let fileManager = FileManager.default
  let xcassetsPath = "../Resources/AssetMedia.xcassets"
  
  do {
    if fileManager.fileExists(atPath: xcassetsPath) {
      try fileManager.removeItem(atPath: xcassetsPath)
    }
    print("Creating directory")
    try fileManager.createDirectory(atPath: xcassetsPath, withIntermediateDirectories: true, attributes: nil)
    
    print("Looping through sections")
    for (sectionName, sectionColors) in colorsLight {
      print("Processing Section: ", sectionName)
      for (name, lightColor) in sectionColors {
        guard let darkSectionColor = colorsDark[sectionName], let darkColor = darkSectionColor[name] else {
          print("Failed: ", sectionName, name)
          return .error
        }
        let colorJSON = createColorJSON(lightColor: lightColor, darkColor: darkColor)
        let colorDir = "\(xcassetsPath)/\(name).colorset"
        
        try fileManager.createDirectory(atPath: colorDir, withIntermediateDirectories: true, attributes: nil)
        
        let jsonData = try JSONSerialization.data(withJSONObject: colorJSON, options: .prettyPrinted)
        let jsonPath = "\(colorDir)/Contents.json"
        fileManager.createFile(atPath: jsonPath, contents: jsonData, attributes: nil)
      }
    }
    print("Contents added to \(xcassetsPath)")
    return .success
  } catch {
    print("Content failed to be added to \(xcassetsPath)")
    print(error)
    return .error
  }
}

func createSwiftFile() -> ReturnCode {
  print("Creating swift file")
  do {
    var mainContent = """
    import SwiftUI
    
    public extension Color { struct BT {} }\n\n
    """
    
    for (group, values) in colorGroups {
      var currentGroup = """
      public extension Color.BT {
        struct \(group.capitalized) {\n
      """
      let inputs = values.map { item in
        "    public static var \(item) = Color(\"\(item)\", bundle: .sharedResources)"
      }.joined(separator: "\n")
      
      currentGroup = currentGroup + inputs + "\n  }\n" + "}\n\n"
      mainContent += currentGroup
    }
    
    let swiftFilePath = "../EcoSortColours.swift"
    try mainContent.write(toFile: swiftFilePath, atomically: true, encoding: .utf8)
    return .success
  } catch {
    print(error)
    return .error
  }
}

//MARK: - Typealias, Constants and Helper Functions
enum ReturnCode: Int32 {
  case success = 0
  case error = 1
}

typealias PrebuildTask = (_ targetPath: URL, _ targetName: String, _ namespace: String) -> ReturnCode

//MARK: - Builder
class Prebuilder {
  func prebuild() -> ReturnCode {
    print("Create color assets")
    let creatAssets = createXCAssets(colorsLight: colorsLight, colorsDark: colorsDark)
    print("Done creating color assets ", creatAssets)
    if (creatAssets == .error) {
      return creatAssets
    }
    
    print("Creating swift file")
    let createSwiftFile = createSwiftFile()
    
    print("Done creating swift file: ", createSwiftFile)
    return createSwiftFile
  }
}

let code = Prebuilder().prebuild()
exit(code.rawValue)

