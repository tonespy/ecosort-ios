//
//  EcoDocumentMediaPicker.swift
//  Platform
//
//  Created by Abubakar Oladeji on 20/03/2025.
//

import SwiftUI
import UniformTypeIdentifiers

public struct EcoDocumentMediaPicker: UIViewControllerRepresentable {

  @Binding var result: EcoAlbumPickerResult?
  let type: EcoAlbumPickerType

  public init(result: Binding<EcoAlbumPickerResult?>, type: EcoAlbumPickerType) {
    self._result = result
    self.type = type
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(parent: self)
  }

  public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    // For images, use UTType.image; for video, use UTType.movie.
    let allowedTypes: [UTType] = {
      switch type {
      case .images:
        return [UTType.image]
      case .video:
        return [UTType.movie, UTType.video]
      }
    }()

    let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes)
    // For images: allow multiple selection; for video: only one selection.
    switch type {
    case .images:
      picker.allowsMultipleSelection = true
    case .video:
      picker.allowsMultipleSelection = false
    }
    picker.delegate = context.coordinator
    picker.modalPresentationStyle = .formSheet
    picker.shouldShowFileExtensions = true
    return picker
  }

  public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
    // No dynamic updates needed.
  }

  public class Coordinator: NSObject, UIDocumentPickerDelegate {
    let parent: EcoDocumentMediaPicker

    init(parent: EcoDocumentMediaPicker) {
      self.parent = parent
    }

    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
      print("documentPicker didPickDocumentsAt called with urls: \(urls)")
      print("Picker type: \(parent.type)")
      switch parent.type {
      case .images:
        print("Processing images...")
        var newImages: [VideoFrameResult] = []
        let dispatchGroup = DispatchGroup()
        for url in urls {
          dispatchGroup.enter()
          // Load image data from each URL.
          DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data), let resized = image.preprocessImage(
                CGSize(width: 256, height: 256)
               ) {
              newImages.append(
                VideoFrameResult(data: data, resizedData: resized, image: image)
              )
            }
            dispatchGroup.leave()
          }
        }
        dispatchGroup.notify(queue: .main) {
          self.parent.result = .images(newImages)
        }
      case .video:
        print("Processing videos...")
        if let url = urls.first {
          do {
            let moveItem = try url.saveVideoToAppDocument(true)
            print("Moved Item Information: ", moveItem)
            Task.detached {
              await MainActor.run {
                self.parent.result = .processing("Extracting frames from video...")
              }

              print("Moved File: ", moveItem)

              let extractedFrames = await moveItem.extractFramesFromVideo()

              await MainActor.run {
                if extractedFrames.isEmpty {
                  self.parent.result = .failed("Unable to extract frames from video.")
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

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      DispatchQueue.main.async {
        self.parent.result = .cancelled
      }
    }
  }
}
