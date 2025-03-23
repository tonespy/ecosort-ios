//
//  UIImage+Extension.swift
//  Asset
//
//  Created by Abubakar Oladeji on 23/03/2025.
//

import Foundation
import SwiftUI

public extension UIImage {
  func resizeImage(targetSize: CGSize) -> [Float32]? {
    UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
    self.draw(in: CGRect(origin: .zero, size: targetSize))
    guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
      UIGraphicsEndImageContext()
      return nil
    }
    UIGraphicsEndImageContext()

    guard let cgImage = resizedImage.cgImage else { return nil }
    let width = Int(targetSize.width)
    let height = Int(targetSize.height)
    let bytesPerPixel = 4
    let bytesPerRow = bytesPerPixel * width
    let bitsPerComponent = 8

    var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    guard let context = CGContext(data: &pixelData,
                                  width: width,
                                  height: height,
                                  bitsPerComponent: bitsPerComponent,
                                  bytesPerRow: bytesPerRow,
                                  space: colorSpace,
                                  bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
    else { return nil }

    context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

    // Convert pixel data to normalized Float32 values (ignoring alpha)
    var floatArray = [Float32]()
    for i in stride(from: 0, to: pixelData.count, by: 4) {
      let r = Float32(pixelData[i]) / 255.0
      let g = Float32(pixelData[i+1]) / 255.0
      let b = Float32(pixelData[i+2]) / 255.0
      floatArray.append(contentsOf: [r, g, b])
    }

    // Verify count: for 256x256 image, expect 256 * 256 * 3 = 196608 float values.
    guard floatArray.count == width * height * 3 else {
      print("Unexpected float array count: \(floatArray.count)")
      return nil
    }

    return floatArray
  }

  func preprocessImage(_ targetSize: CGSize) -> Data? {
    guard let floatArray = self.resizeImage(targetSize: targetSize) else {
      return nil
    }
    
    let inputData = floatArray.withUnsafeBufferPointer {
      Data(buffer: $0)
    }

    return inputData
  }
}
