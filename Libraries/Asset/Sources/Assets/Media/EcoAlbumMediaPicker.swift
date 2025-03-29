//
//  EcoAlbumMediaPicker.swift
//  Platform
//
//  Created by Abubakar Oladeji on 20/03/2025.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

public enum EcoAlbumPickerResult {
  case images([VideoFrameResult])
  case video(URL, [VideoFrameResult])
  case processing(String)
  case failed(String)
  case cancelled

  public var images: [VideoFrameResult]? {
    switch self {
    case .images(let images):
      return images
    case .video(_, let frames):
      return frames
    case .processing, .failed, .cancelled:
      return []
    }
  }

  public var url: URL? {
    switch self {
    case .video(let url, _):
      return url
    default:
      return nil
    }
  }
}

public enum EcoAlbumPickerType {
  case images
  case video
}

public struct EcoAlbumMediaPicker: UIViewControllerRepresentable {

  @Binding var result: EcoAlbumPickerResult?
  let type: EcoAlbumPickerType

  public init(result: Binding<EcoAlbumPickerResult?>, type: EcoAlbumPickerType) {
    self._result = result
    self.type = type
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  public func makeUIViewController(context: Context) -> some PHPickerViewController {
    var config = PHPickerConfiguration()
    switch type {
      case .images:
        config.filter = .images
        config.selectionLimit = 0
    case .video:
      config.filter = .videos
      config.selectionLimit = 1
    }

    let picker = PHPickerViewController(configuration: config)
    picker.delegate = context.coordinator
    return picker
  }

  public func updateUIViewController(
    _ uiViewController: UIViewControllerType,
    context: Context
  ) {}

  public class Coordinator: NSObject, PHPickerViewControllerDelegate {
    let parent: EcoAlbumMediaPicker

    init(parent: EcoAlbumMediaPicker) {
      self.parent = parent
    }

    private func processImageResults(
      _ results: [PHPickerResult],
      dispatchGroup: DispatchGroup
    ) {
      var newImages: [VideoFrameResult] = []

      for result in results {
        let provider = result.itemProvider
        if provider.canLoadObject(ofClass: UIImage.self) {
          dispatchGroup.enter()
          provider.loadObject(ofClass: UIImage.self) {
 image,
 error in
            defer { dispatchGroup.leave() }
            if let image = image as? UIImage,
               let data = image.jpegData(compressionQuality: 0.8),
               let resized = image.preprocessImage(
                CGSize(width: 256, height: 256)
               ) {
              newImages.append(
                VideoFrameResult(data: data, resizedData: resized, image: image)
              )
            }
          }
        }
      }
      dispatchGroup.notify(queue: .main) {
        self.parent.result = .images(newImages)
      }
    }

    private func processVideoResult(_ results: [PHPickerResult]) {
      guard let result = results.first else { return }
      let provider = result.itemProvider
      let videoUTI = UTType.movie.identifier  // UTI for movie files.

      if provider.hasItemConformingToTypeIdentifier(videoUTI) {
        provider.loadFileRepresentation(forTypeIdentifier: videoUTI) {
 url,
 error in
          if let url = url {
            do {
              let moveItem = try url.saveVideoToAppDocument(false)
              Task.detached {
                await MainActor.run {
                  self.parent.result = 
                    .processing("Extracting frames from video...")
                }
                let extractedFrames = await moveItem.extractFramesFromVideo()

                await MainActor.run {
                  if extractedFrames.isEmpty {
                    self.parent.result = .failed("Error extracting frames from video")
                  } else {
                    self.parent.result = .video(moveItem, extractedFrames)
                  }
                }
              }
            } catch {
              print("Error saving video: \(error)")
              DispatchQueue.main.async {
                self.parent.result = .failed("Unable to access video file.")
              }
            }
          }
        }
      }
    }

    public func picker(
      _ picker: PHPickerViewController,
      didFinishPicking results: [PHPickerResult]
    ) {
      picker.dismiss(animated: true)

      guard !results.isEmpty else {
        parent.result = .cancelled
        return
      }

      switch parent.type {
      case .images:
        let dispatchGroup = DispatchGroup()
        processImageResults(results, dispatchGroup: dispatchGroup)
      case .video:
        processVideoResult(results)
      }
    }
  }
}
