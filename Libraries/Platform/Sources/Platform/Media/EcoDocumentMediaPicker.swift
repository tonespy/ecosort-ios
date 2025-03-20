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
        return [UTType.movie]
      }
    }()

    let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedTypes, asCopy: true)
    // For images: allow multiple selection; for video: only one selection.
    switch type {
    case .images:
      picker.allowsMultipleSelection = true
    case .video:
      picker.allowsMultipleSelection = false
    }
    picker.delegate = context.coordinator
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
      switch parent.type {
      case .images:
        var newImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        for url in urls {
          dispatchGroup.enter()
          // Load image data from each URL.
          DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
              newImages.append(image)
            }
            dispatchGroup.leave()
          }
        }
        dispatchGroup.notify(queue: .main) {
          self.parent.result = .images(newImages)
        }
      case .video:
        if let url = urls.first {
          DispatchQueue.main.async {
            self.parent.result = .video(url)
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
