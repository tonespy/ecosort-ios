//
//  UploadProgressDelegate.swift
//  Platform
//
//  Created by Abubakar Oladeji on 27/03/2025.
//

import Foundation

class UploadProgressDelegate: NSObject, URLSessionTaskDelegate {
  // This closure will be called with the upload progress (0.0 - 1.0)
  var progressHandler: ((Float) -> Void)?

  func urlSession(_ session: URLSession, task: URLSessionTask,
                  didSendBodyData bytesSent: Int64,
                  totalBytesSent: Int64,
                  totalBytesExpectedToSend: Int64) {
    let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    self.progressHandler?(progress)
//    DispatchQueue.main.async {
//
//    }
  }
}
