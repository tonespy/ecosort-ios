//
//  APILoggingMiddleware.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public struct APILoggingMiddleware: APIClient.Middleware {
  private var logger: Logging
  
  public init(logger: Logging) {
    self.logger = logger
  }
  
  public func intercept(_ request: URLRequest) async throws -> (URLRequest) {
    logger.log(message: "Request: \(request.customDescription)")
    return request
  }

  public func logResponse(_ response: URLResponse, data: Data?) {
    var message = "Response: \(response.customDescription)"
    if let data = data, let pretty = prettyPrintedJSONString(from: data) {
      message += "\nData: \(pretty))"
    }
    logger.log(message: message)
  }

  private func prettyPrintedJSONString(from data: Data) -> String? {
    do {
      let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
      let prettyData = try JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted])
      return String(data: prettyData, encoding: .utf8)
    } catch {
      print("Error converting data to JSON: \(error)")
      return nil
    }
  }
}
