//
//  APIClient+Mock.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public extension APIClient {
  /// Stubs error to respond the next HTTP request with.
  /// - Parameter error: error of the response to the next request.
  /// - Parameter code: HTTP status code for the response. Defaults to 400.
  /// - Parameter endpoint: Path to the endpoint which the stubbed data should respond to. Defaults to a generic endpoint that responds to any requests.
  func stub(error: Error, code: Int, endpoint: String? = nil) -> APIClient {
    MockedURLProtocol.stub(error: error, code: code, endpoint: endpoint ?? MockedURLProtocol.endpoint)
    return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
  }
  
  /// Stubs a string in JSON format to respond the next HTTP request with.
  /// - Parameter json: A string in JSON format with the contents of the response to the next request.
  /// - Parameter code: HTTP status code for the response. Defaults to 200.
  /// - Parameter endpoint: Path to the endpoint which the stubbed data should respond to. Defaults to a generic endpoint that responds to any requests.
  func stub(json: String, code: Int, endpoint: String? = nil) -> APIClient {
    MockedURLProtocol.stub(json: json, code: code, endpoint: endpoint ?? MockedURLProtocol.endpoint)
    return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
  }
  
  /// Clears all stubs.
  func reset() -> APIClient {
    MockedURLProtocol.reset()
    return copy(session: URLSession(configuration: URLSessionConfiguration.testing))
  }
}

public extension URLSessionConfiguration {
  static var testing: URLSessionConfiguration {
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [MockedURLProtocol.self] as [AnyClass]
    return configuration
  }
}
