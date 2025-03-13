//
//  MockedURLProtocol.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public struct ExpectedResponse {
  let statusCode: Int
  let content: Result<Data, Error>
  
  init(data: Data, statusCode: Int) {
    self.statusCode = statusCode
    self.content = .success(data)
  }
  
  init(error: Error, statusCode: Int) {
    self.statusCode = statusCode
    self.content = .failure(error)
  }
}

public class MockedURLProtocol: URLProtocol {
  public static let endpoint = "<mocked-endpoint>"
  private static var stubs: [String: [ExpectedResponse]] = [:]
  
  private static func stub(response: ExpectedResponse, for endpoint: String) {
    if let responses = stubs[endpoint] {
      stubs[endpoint] = responses + [response]
    } else {
      stubs[endpoint] = [response]
    }
  }
  
  /// Clears all stubs.
  public static func reset() {
    stubs = [:]
  }
  
  /// Stub methods
  public static func stub(data: Data, code: Int, endpoint: String = endpoint) {
    stub(response: ExpectedResponse(data: data, statusCode: code),
         for: endpoint)
  }
  
  public static func stub(error: Error, code: Int, endpoint: String = endpoint) {
    stub(response: ExpectedResponse(error: error, statusCode: code),
         for: endpoint)
  }
  
  public static func stub(json: String, code: Int, endpoint: String = endpoint) {
    stub(response: ExpectedResponse(data: json.data(using: .utf8)!, statusCode: code),
         for: endpoint)
  }
  
  public static func stub(contentsOfFile url: URL, code: Int, endpoint: String = endpoint) {
    let content = try! String(contentsOf: url, encoding: .utf8)
    stub(json: content, code: code, endpoint: endpoint)
  }
  
  public static func response(for request: URLRequest) -> ExpectedResponse? {
    if let url = request.url?.absoluteString {
      for endpoint in stubs {
        if url.hasSuffix(endpoint.key) {
          return consume(endpoint.key)
        }
      }
    }
    return consume(endpoint)
  }
  
  public static func consume(_ endpoint: String) -> ExpectedResponse? {
    let queue = stubs[endpoint]
    let response = queue?.first
    stubs[endpoint] = Array(queue?.dropFirst() ?? [])
    return response
  }
  
  public override static func canInit(with request: URLRequest) -> Bool {
    return true
  }
  
  public override static func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }
  
  public override func startLoading() {
    guard let stub = MockedURLProtocol.response(for: request) else {
      let error = NetworkError.unknownError(message: "No response stubbed for request")
      client?.urlProtocol(self, didFailWithError: error)
      return
    }
    
    let header = request.allHTTPHeaderFields
    
    let response = HTTPURLResponse(
      url: request.url!,
      statusCode: stub.statusCode,
      httpVersion: nil,
      headerFields: header
    )!
    
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    
    switch stub.content {
    case .failure(let error):
      client?.urlProtocol(self, didFailWithError: error)
      return
    case .success(let data):
      client?.urlProtocol(self, didLoad: data)
      client?.urlProtocolDidFinishLoading(self)
      return
    }
  }
  
  public override func stopLoading() { }
}
