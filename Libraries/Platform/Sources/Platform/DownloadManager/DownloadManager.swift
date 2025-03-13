//
//  DownloadManager.swift
//  Platform
//
//  Created by Abubakar Oladeji on 03/02/2025.
//

import Foundation
import Combine
import SwiftUI

/// A protocol to abstract URLSession for testability.
public protocol URLSessionProtocol {
  func downloadTask(with request: URLRequest) -> URLSessionDownloadTask
}

extension URLSession: URLSessionProtocol { }

/// A manager that downloads a file in the background and publishes updates.
public class DownloadManager: NSObject, ObservableObject {
  
  @Published public private(set) var modelVersions: [PredictVersionModelVersion] = []
  
  /// The current download progress (0.0 to 1.0)
  @Published public var progress: Double = 0.0

  @Published public var currentQueItemWithProgress: (
    version: String,
    url: URL,
    progress: Double
  )? = nil

  @Published public var isDownloadInProgress: Bool = false

  @Published public var currentQueueItem: (version: String, url: URL)? = nil

  @Published public var failEverything: Bool = false

  @Published public var downloadQueue: [(version: String, url: URL)] = []

  /// The URLSession used for downloading. (Injected for testing purposes.)
  private var urlSession: URLSessionProtocol
  
  private var sessionWithDelegate: URLSession?
  
  /// Keep a reference to the download task.
  private var downloadTask: URLSessionDownloadTask?
  
  /// Completion handler when download finishes.
  public var completionHandler: ((URL?, String, Bool) -> Void)?

  public var failureHandler: ((URL?, Error, String) -> Void)?

  /// Handler called when a download is cancelled.
  public var cancellationHandler: ((String) -> Void)?

  /// Use dependency injection to allow for testability. The session parameter defaults to a background session.
  public init(urlSession: URLSessionProtocol? = nil) {
    // Create a background configuration so downloads can run even when the app is in the background.
    if let session = urlSession {
      self.urlSession = session
    } else {
      let configuration = URLSessionConfiguration.default
      self.urlSession = URLSession(configuration: configuration)
    }
    super.init()
  }

  public func checkQueue(_ version: String) {
    guard let indexOfQueueItem = downloadQueue.map(\.version).firstIndex(of: version) else {
      downloadQueue.removeAll()
      currentQueueItem = nil
      return
    }

    downloadQueue.remove(at: indexOfQueueItem)
    guard !downloadQueue.isEmpty, let first = downloadQueue.first else {
      currentQueueItem = nil
      return
    }
    
    beginDownload(from: first.url)
  }

  public func startDownload(from url: URL, version: String) {
    if getItemFromQueue(version) == nil {
      downloadQueue.append((version, url))
    }

    guard !isDownloadInProgress else { return }
    currentQueueItem = (version, url)
    beginDownload(from: url)
  }

  /// Cancels the currently active download. Notifies observers about the cancellation and moves to the next item in the queue.
  public func cancelCurrentDownload(version: String) {
    if let queueVersion = currentQueueItem?.version, version == queueVersion {
      downloadTask?.cancel()
      DispatchQueue.main.async {
        self.isDownloadInProgress = false
        self.cancellationHandler?(version)
        self.checkQueue(version)
      }
      return
    }

    downloadTask?.suspend()
    downloadQueue.removeAll { queueItem in
      queueItem.version == version
    }

    downloadTask?.resume()
    DispatchQueue.main.async {
      self.cancellationHandler?(version)
    }
  }

  /// Starts the download from the given URL.
  private func beginDownload(from url: URL) {
    guard let modelKey = Bundle.main.object(forInfoDictionaryKey: "MODEL_RELEASE_API_KEY") as? String else {
      return
    }

    isDownloadInProgress = true
    var request = URLRequest(url: url)

    // Add request headers
    request.setValue("2022-11-28", forHTTPHeaderField: "X-GitHub-Api-Version")
    request.setValue("application/octet-stream", forHTTPHeaderField: "Accept")
    request.setValue("Bearer \(modelKey)", forHTTPHeaderField: "Authorization")

    if let session = urlSession as? URLSession {
      let configuration = session.configuration
      let newSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
      self.sessionWithDelegate = newSession
      self.downloadTask = newSession.downloadTask(with: request)
      self.downloadTask?.resume()
    } else {
      // For testing with a mock session, simply use downloadTask
      downloadTask = urlSession.downloadTask(with: request)
      downloadTask?.resume()
    }
  }

  /// Simulates a download process over the given duration.
  public func mockStartDownload(duration: TimeInterval = 20.0, updateInterval: TimeInterval = 0.5) {
    // Reset the download state
    progress = 0.0
    
    // Calculate the number of steps and the progress increment per step.
    let totalSteps = Int(duration / updateInterval)
    var currentStep = 0
    
    Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { timer in
      currentStep += 1
      self.progress = min(Double(currentStep) / Double(totalSteps), 1.0)
      // When the download simulation is complete, invalidate the timer.
      if currentStep >= totalSteps {
        timer.invalidate()
      }
    }
  }
  
  public func updateModelVersions(versions: [PredictVersionModelVersion]) {
    let sortVersions = versions.sorted { v1, v2 -> Bool in
      v1.version > v2.version
    }
    self.modelVersions = sortVersions
  }

  public func retrieveModelForVersion(_ version: String) -> PredictVersionModelVersion? {
    let model = self.modelVersions.first { $0.version == version }
    return model
  }

  private func getItemFromQueue(_ version: String) -> (version: String, url: URL)? {
    let queueItem = self.downloadQueue.first { $0.version == version }
    return queueItem
  }

  private func getItemFromQueue(_ url: URL) -> (version: String, url: URL)? {
    let queueItem = self.downloadQueue.first { $0.url == url }
    return queueItem
  }
}

extension DownloadManager: URLSessionDownloadDelegate {
  
  // Delegate method to receive progress updates.
  public func urlSession(_ session: URLSession,
                         downloadTask: URLSessionDownloadTask,
                         didWriteData bytesWritten: Int64,
                         totalBytesWritten: Int64,
                         totalBytesExpectedToWrite: Int64) {
//    print("Progress: \(totalBytesWritten)/\(totalBytesExpectedToWrite)")
    // Update progress on the main thread so UI can subscribe
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
      self.progress = progress
      if let currentQueueItem = self.currentQueueItem {
        self.currentQueItemWithProgress = (
          currentQueueItem.version,
          currentQueueItem.url,
          progress
        )
      }
    }
  }
  
  public func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
    print("Sending self.totalBytesExpectedToSend: \(totalBytesExpectedToSend)")
  }

  private func getDocumentsDirectory() throws -> URL {
    // Get the documents directory url
    let path = try FileManager.default.url(
      for: .documentDirectory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    ).appendingPathComponent("tflite_models", isDirectory: true)

    try FileManager.default
      .createDirectory(at: path, withIntermediateDirectories: true)
    return path
  }

  // Delegate method called when download finishes
  public func urlSession(_ session: URLSession,
                         downloadTask: URLSessionDownloadTask,
                         didFinishDownloadingTo location: URL) {
    print("Download Completed: \(location)")

    guard let mainUrl = downloadTask.originalRequest?.url, let item = getItemFromQueue(mainUrl) else {
      publishCompletion(location: location, "Unknown", false)
      return
    }

    do {
      let fileUrl = try getDocumentsDirectory()
        .appendingPathComponent("v\(item.version)")
        .appendingPathExtension("tflite")

      try FileManager.default.moveItem(at: location, to: fileUrl)
      print("File moved to: \(fileUrl.path())")
      publishCompletion(location: fileUrl, item.version, true)
    } catch {
      print("Error moving file: \(error)")
      publishCompletion(location: location, item.version, false)
    }
  }

  private func publishCompletion(
    location: URL,
    _ version: String,
    _ isSaved: Bool
  ) {
    self.sessionWithDelegate = nil
    DispatchQueue.main.async { [weak self] in
      self?.isDownloadInProgress = false
      self?.completionHandler?(isSaved ? location : nil, version, isSaved)
      self?.checkQueue(version)
    }
  }

  // Optional: handle errors if needed.
  public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let errorInfo = error else { return }

    // Check if the error is a cancellation.
    if (errorInfo as NSError).code == NSURLErrorCancelled {
      return
    }

    DispatchQueue.main.async { [weak self] in
      self?.isDownloadInProgress = false

      guard let (version, url) = self?.currentQueueItem else {
        self?.failureHandler?(nil, errorInfo, "Unknown")
        self?.checkQueue("Unknwon")
        return
      }

      self?.failureHandler?(url, errorInfo, version)
      self?.checkQueue(version)
    }
  }
}
