//
//  URL+Extension.swift
//  Asset
//
//  Created by Abubakar Oladeji on 02/03/2025.
//

import AVFoundation
import UIKit
import CryptoKit

public struct VideoFrameResult: Sendable {
  public let data: Data
  public let resizedData: Data
  public let image: UIImage

  public init(data: Data, resizedData: Data, image: UIImage) {
    self.data = data
    self.resizedData = resizedData
    self.image = image
  }
}

public extension URL {
  func extractFramesFromVideo() async -> [VideoFrameResult] {
    var framesData = [VideoFrameResult]()
    var seenHashes = Set<String>()

    let videoURL = self
    // Start security-scoped access.
    guard videoURL.startAccessingSecurityScopedResource() else {
      print("Could not access security scoped resource for video URL")
      return []
    }
    defer { videoURL.stopAccessingSecurityScopedResource() }

    let asset = AVAsset(url: videoURL)

    do {
      // Load video tracks using the new async API.
      let (videoTracks, _, _) = try await asset.load(
        .tracks,
        .duration,
        .preferredTransform
      )

      guard let videoTrack = videoTracks.first else { return [] }

      // Load the frame rate and duration using async load.
      let frameRate = try await videoTrack.load(.nominalFrameRate)
      let duration = try await asset.load(.duration)
      let durationSeconds = CMTimeGetSeconds(duration)

      // Calculate a time increment based on the frame rate.
      // If frameRate is 0, use a fallback (e.g. 0.1 seconds).
      let timeIncrement = frameRate > 0 ? 1.0 / Double(frameRate) : 0.1

      // Build an array of NSValue-wrapped CMTime values.
      var times = [NSValue]()
      for second in stride(from: 0.0, through: durationSeconds, by: timeIncrement) {
        let time = CMTime(seconds: second, preferredTimescale: duration.timescale)
        times.append(NSValue(time: time))
      }

      // Create the image generator and set tolerances to zero for frame-exact extraction.
      let generator = AVAssetImageGenerator(asset: asset)
      generator.requestedTimeToleranceBefore = .zero
      generator.requestedTimeToleranceAfter = .zero

      // Loop through the times and extract images synchronously.
      for timeValue in times {
        let time = timeValue.timeValue
        var actualTime = CMTime.zero
        do {
          let cgImage = try generator.copyCGImage(at: time, actualTime: &actualTime)
          let uiImage = UIImage(cgImage: cgImage)
          if let imageData = uiImage.jpegData(compressionQuality: 0.8), let resized = uiImage.preprocessImage(CGSize(width: 256, height: 256)) {
            // Compute the SHA256 hash for deduplication.
            let hash = SHA256.hash(data: imageData)
            let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
            if !seenHashes.contains(hashString) {
              framesData
                .append(
                  VideoFrameResult(
                    data: imageData,
                    resizedData: resized,
                    image: uiImage
                  )
                )
              seenHashes.insert(hashString)
            }
          }
        } catch {
          print("Failed to generate image at time \(time): \(error)")
        }
      }
    } catch {
      print("Error extracting frames: \(error)")
      return []
    }

    return framesData
  }

  /// Extracts unique video frames (as JPEG Data) using async/await.
  /// Duplicate frames (based on SHA256 hash) are filtered out.
  func extractUniqueFramesFromVideo() async -> [VideoFrameResult] {
    var framesData = [VideoFrameResult]()
    var seenHashes = Set<String>()

    let videoURL = self
    // Try to start security-scoped access.
    guard videoURL.startAccessingSecurityScopedResource() else {
      print("Could not access security scoped resource for video URL")
      return []
    }
    defer { videoURL.stopAccessingSecurityScopedResource() }

    let asset = AVAsset(url: videoURL)

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
          if let imageData = uiImage.jpegData(compressionQuality: 0.8), let resized = uiImage.preprocessImage(CGSize(width: 256, height: 256)) {
            // Compute SHA256 hash of the frame's data.
            let hash = SHA256.hash(data: imageData)
            let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
            // Only add the frame if its hash hasn't been seen.
            if !seenHashes.contains(hashString) {
              framesData
                .append(
                  VideoFrameResult(
                    data: imageData,
                    resizedData: resized,
                    image: uiImage
                  )
                )
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

  static let videoFolderName: String = "ecosort_user_videos"

  func saveVideoToAppDocument() throws -> URL {
    let path = try FileManager
      .default
      .url(
        for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      .appendingPathComponent("ecosort_user_videos", isDirectory: true)

    if FileManager.default.fileExists(atPath: path.path) {
      try FileManager.default.removeItem(at: path)
    }

    print("Current file path: \(self)")
    try FileManager.default.copyItem(at: self, to: path)

    let destinationUrl = path.appendingPathComponent(self.lastPathComponent)

    print("New File Path: \(destinationUrl)")
    return destinationUrl
  }
}
