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
  case images([UIImage])
  case video(URL)
  case cancelled
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
      var newImages: [UIImage] = []

      for result in results {
        let provider = result.itemProvider
        if provider.canLoadObject(ofClass: UIImage.self) {
          dispatchGroup.enter()
          provider.loadObject(ofClass: UIImage.self) { image, error in
            defer { dispatchGroup.leave() }
            if let image = image as? UIImage {
              newImages.append(image)
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
        provider.loadFileRepresentation(forTypeIdentifier: videoUTI) { url, error in
          if let url = url {
            DispatchQueue.main.async {
              self.parent.result = .video(url)
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
