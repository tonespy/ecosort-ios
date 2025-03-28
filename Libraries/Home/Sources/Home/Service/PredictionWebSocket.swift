//
//  PredictionWebSocket.swift
//  Home
//
//  Created by Abubakar Oladeji on 27/03/2025.
//

import Foundation
import Platform

// /predict/websocket

struct WSPrediction: RequestModelConforms {
  let jobID: String
  let prediction: PredictionClasses
  let imageName: String
  let status: String

  var strippedImageName: String {
    imageName.replacingOccurrences(of: ".jpg", with: "")
  }
}

struct WSProgress: RequestModelConforms {
  let predictions: [WSPrediction]
  let status: String
  let progress: Double
}

enum WSProgressResult {
  case update(WSProgress)
  case failure(Error)
}

extension PredictionWebSocket: @unchecked Sendable {}

final class PredictionWebSocket {
  private let jobId: String
  private let url: URL
  private let apiKey: String
  var predictionResult: ((WSProgressResult) -> Void)?
  var isProcessingComplete: Bool = false

  var webSocketTask: URLSessionWebSocketTask?

  init?(jobId: String) {
    let baseUrl = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String
    let websocketProtocol = Bundle.main.object(forInfoDictionaryKey: "WEBSOCKET_PROTOCOL") as? String
    guard
      let baseUrl,
      let websocketProtocol,
      let url = URL(string: "\(websocketProtocol)://\(baseUrl)/v1/predict/websocket?jobID=\(jobId)"), let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_REQ_KEY") as? String else { return nil }
    self.jobId = jobId
    self.url = url
    self.apiKey = apiKey
  }

  func connectWebSocket() {
    // Create a custom URLSessionConfiguration that includes the API key header.
    let config = URLSessionConfiguration.default
    config.httpAdditionalHeaders = ["X-API-Key": apiKey]

    // Create a URLSession with this configuration.
    let session = URLSession(configuration: config)
    webSocketTask = session.webSocketTask(with: url)
    webSocketTask?.resume()
    listenForMessages()
  }

  private func handleMessage(_ message: String) {
    do {
      let data = message.data(using: .utf8)!
      let jsonDecoder = JSONDecoder()
      let progress = try jsonDecoder.decode(WSProgress.self, from: data)
      self.isProcessingComplete = progress.progress >= 100
      DispatchQueue.main.async {
        self.predictionResult?(.update(progress))
      }
    } catch {
      if !isProcessingComplete {
        DispatchQueue.main.async {
          self.predictionResult?(.failure(error))
        }
      }
    }
  }

  func listenForMessages() {
    webSocketTask?.receive { result in
      switch result {
      case .failure(let error):
        if !self.isProcessingComplete {
          self.predictionResult?(WSProgressResult.failure(error))
        }
      case .success(let message):
        switch message {
        case .data(let data):
//          print("Data ===================================================================================================================\n")
          if let text = String(data: data, encoding: .utf8) {
//            print("Text Info: ", text)
            self.handleMessage(text)
          }
          // Continue listening for messages
//          self.listenForMessages()
        case .string(let string):
//          print("String ===================================================================================================================\n")
//          print("Closing connection: ", string)
          self.handleMessage(string)
          self.listenForMessages()
        @unknown default:
          print("Something else received")
          // Continue listening for messages
          self.listenForMessages()
        }
      }
    }
  }

  // Functions to send control messages (pause, stop, continue)
  func sendControlAction(_ action: String) {
    let messageDict = ["action": action]
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: messageDict, options: [])
      if let jsonString = String(data: jsonData, encoding: .utf8) {
        let message = URLSessionWebSocketTask.Message.string(jsonString)
        webSocketTask?.send(message) { error in
          if let error = error {
            print("Error sending message: \(error)")
          }
        }
      }
    } catch {
      print("JSON error: \(error)")
    }
  }
}
