//
//  URL+Extension.swift
//  Asset
//
//  Created by Abubakar Oladeji on 02/03/2025.
//

import AVFoundation
import UIKit
import CryptoKit

public extension URL {
  /// Extracts unique video frames (as JPEG Data) using async/await.
  /// Duplicate frames (based on SHA256 hash) are filtered out.
  func extractUniqueFramesFromVideo() async -> [Data] {
    var framesData = [Data]()
    var seenHashes = Set<String>()
    let asset = AVAsset(url: self)

    do {
      // Asynchronously load video tracks.
      let videoTracks = try await asset.loadTracks(withMediaType: .video)
      guard let videoTrack = videoTracks.first else {
        return []
      }

      let reader = try AVAssetReader(asset: asset)
      let outputSettings: [String: Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
      ]
      let trackOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: outputSettings)

      if reader.canAdd(trackOutput) {
        reader.add(trackOutput)
      }

      reader.startReading()

      // Create a CIContext once.
      let context = CIContext()

      while let sampleBuffer = trackOutput.copyNextSampleBuffer(),
            let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
          let uiImage = UIImage(cgImage: cgImage)
          if let imageData = uiImage.jpegData(compressionQuality: 0.8) {
            // Compute SHA256 hash of the frame's data.
            let hash = SHA256.hash(data: imageData)
            let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
            // Only add the frame if its hash hasn't been seen.
            if !seenHashes.contains(hashString) {
              framesData.append(imageData)
              seenHashes.insert(hashString)
            }
          }
        }
      }
    } catch {
      print("Error extracting frames: \(error)")
      return []
    }

    return framesData
  }
}
