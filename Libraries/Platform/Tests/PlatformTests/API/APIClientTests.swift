//
//  APIClientTests.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Testing
import Foundation
@testable import Platform

@Suite(.serialized)
struct APIClientTests {
  
  // MARK: - Helper Types
  
  struct TestResponse: DecodableType {
    let message: String
    let code: Int
  }
  
  struct TestAPISpecification: APIClient.APISpecification {
    var endpoint: String { "/test-endpoint" }
    var method: APIClient.HttpMethod { .get }
    var returnType: DecodableType.Type { TestResponse.self }
    var body: Data? { nil }
  }
  
  struct InvalidURLAPISpecification: APIClient.APISpecification {
    var endpoint: String { " " } // Invalid endpoint to simulate invalid URL
    var method: APIClient.HttpMethod { .get }
    var returnType: DecodableType.Type { TestResponse.self }
    var body: Data? { nil }
  }
  
  struct ErrorThrowingMiddleware: APIClient.Middleware {
    func intercept(_ request: URLRequest) async throws -> URLRequest {
      throw NetworkError.invalidData
    }
  }
  
  // MARK: - Tests
  
  @Test
  func testSuccessfulRequest() async throws {
    // Arrange
    let baseURL = URL(string: "https://example.com")!
    var apiClient = APIClient(baseURL: baseURL)
    let testJSON = """
        {
            "message": "success",
            "code": 200
        }
        """
    apiClient = apiClient.stub(json: testJSON, code: 200, endpoint: "/test-endpoint")
    let spec = TestAPISpecification()
    
    // Act
    let response = try await apiClient.sendRequest(spec) as! TestResponse
    
    // Assert
    #expect(response.message == "success")
    #expect(response.code == 200)
  }
  
  @Test
  func testInvalidURL() async {
    // Arrange
    let baseURL = URL(string: "https://example.com")!
    let apiClient = APIClient(baseURL: baseURL)
    let spec = InvalidURLAPISpecification()
    
    // Act & Assert
    await xctAssertThrowsErrorAsync(try await apiClient.sendRequest(spec)) { error in
      #expect(error is NetworkError)
      #expect(error as? NetworkError == NetworkError.invalidURL)
    }
  }
  
  @Test
  func testRequestWithMiddleware() async throws {
    // Arrange
    let baseURL = URL(string: "https://example.com")!
    let middleware = APIAuthorizationMiddleware()
    var apiClient = APIClient(baseURL: baseURL, middleware: [middleware])
    let testJSON = """
        {
            "message": "success with middleware",
            "code": 200
        }
        """
    apiClient = apiClient.stub(json: testJSON, code: 200, endpoint: "/test-endpoint")
    let spec = TestAPISpecification()
    
    // Act
    let response = try await apiClient.sendRequest(spec) as! TestResponse
    
    // Assert
    #expect(response.message == "success with middleware")
    #expect(response.code == 200)
  }
  
  @Test
  func testMiddlewareThrowsError() async {
    // Arrange
    let baseURL = URL(string: "https://example.com")!
    let middleware = ErrorThrowingMiddleware()
    let apiClient = APIClient(baseURL: baseURL, middleware: [middleware])
    let spec = TestAPISpecification()
    
    // Act & Assert
    await xctAssertThrowsErrorAsync(try await apiClient.sendRequest(spec)) { error in
      #expect(error is NetworkError)
      #expect(error as? NetworkError == NetworkError.invalidData)
    }
  }
  
  @Test
  func testResponseWithErrorStatusCode() async {
    // Arrange
    let baseURL = URL(string: "https://example.com")!
    var apiClient = APIClient(baseURL: baseURL)
    let testJSON = """
        {
            "message": "not found",
            "code": 404
        }
        """
    apiClient = apiClient.stub(json: testJSON, code: 404, endpoint: "/test-endpoint")
    let spec = TestAPISpecification()
    
    // Act & Assert
    await xctAssertThrowsErrorAsync(try await apiClient.sendRequest(spec)) { error in
      #expect(error is NetworkError)
      #expect(error as? NetworkError == NetworkError.requestFailed(statusCode: 404))
    }
  }
  
  @Test
  func testDecodingFailure() async {
    // Arrange
    struct InvalidTestResponse: DecodableType {
      let invalidField: String
    }
    struct InvalidTestAPISpecification: APIClient.APISpecification {
      var endpoint: String { "/test-endpoint" }
      var method: APIClient.HttpMethod { .get }
      var returnType: DecodableType.Type { InvalidTestResponse.self }
      var body: Data? { nil }
    }
    
    let baseURL = URL(string: "https://example.com")!
    var apiClient = APIClient(baseURL: baseURL)
    let testJSON = """
        {
            "message": "success",
            "code": 200
        }
        """
    apiClient = apiClient.stub(json: testJSON, code: 200, endpoint: "/test-endpoint")
    let spec = InvalidTestAPISpecification()
    
    // Act & Assert
    await xctAssertThrowsErrorAsync(try await apiClient.sendRequest(spec)) { error in
      #expect(error is DecodingError)
    }
  }
  
  @Test
  func testInvalidResponse() async {
    // Arrange
    class InvalidResponseURLProtocol: URLProtocol {
      override class func canInit(with request: URLRequest) -> Bool {
        return true
      }
      override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
      }
      override func startLoading() {
        client?.urlProtocol(self, didReceive: URLResponse(), cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
      }
      override func stopLoading() {}
    }
    
    let configuration = URLSessionConfiguration.default
    configuration.protocolClasses = [InvalidResponseURLProtocol.self]
    let session = URLSession(configuration: configuration)
    let baseURL = URL(string: "https://example.com")!
    let apiClient = APIClient(baseURL: baseURL).copy(session: session)
    let spec = TestAPISpecification()
    
    // Act & Assert
    await xctAssertThrowsErrorAsync(try await apiClient.sendRequest(spec)) { error in
      #expect(error is NetworkError)
      #expect(error as? NetworkError == NetworkError.invalidResponse)
    }
  }
  
  @Test
  func testCopySessionBehavior() async throws {
    // Arrange
    class CustomURLProtocol: URLProtocol {
      static var requestCount = 0
      
      override class func canInit(with request: URLRequest) -> Bool {
        return true
      }
      
      override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
      }
      
      override func startLoading() {
        CustomURLProtocol.requestCount += 1
        let response = HTTPURLResponse(
          url: request.url!,
          statusCode: 200,
          httpVersion: nil,
          headerFields: nil
        )!
        let data = """
                {
                    "message": "response from custom session",
                    "code": 200
                }
                """.data(using: .utf8)!
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocolDidFinishLoading(self)
      }
      
      override func stopLoading() {}
    }
    
    let customConfiguration = URLSessionConfiguration.default
    customConfiguration.protocolClasses = [CustomURLProtocol.self]
    let customSession = URLSession(configuration: customConfiguration)
    
    let baseURL = URL(string: "https://example.com")!
    let originalClient = APIClient(baseURL: baseURL)
    let copiedClient = originalClient.copy(session: customSession)
    
    let spec = TestAPISpecification()
    
    // Act
    let response = try await copiedClient.sendRequest(spec) as! TestResponse
    
    // Assert
    #expect(response.message == "response from custom session")
    #expect(response.code == 200)
    #expect(CustomURLProtocol.requestCount == 1)
  }
  
  @Test
  func testCustomDescription() {
    // Arrange
    var request = URLRequest(url: URL(string: "https://example.com")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    let bodyData = """
        {
            "key": "value"
        }
        """.data(using: .utf8)
    request.httpBody = bodyData
    
    // Act
    let description = request.customDescription
    
    // Assert
    let expectedDescription = """
        POST https://example.com
        Headers: ["Content-Type": "application/json"]
        Body: {
            "key": "value"
        }
        """
    #expect(description == expectedDescription)
  }
  
  @Test()
  func testResetStubs() async throws {
    // Arrange
    let baseURL = URL(string: "https://example.com")!
    var apiClient = APIClient(baseURL: baseURL)
    let testJSON = """
        {
            "message": "stubbed response",
            "code": 200
        }
        """
    apiClient = apiClient.stub(json: testJSON, code: 200, endpoint: "/test-endpoint")
    let spec = TestAPISpecification()
    
    // Act
    let responseBeforeReset = try await apiClient.sendRequest(spec) as! TestResponse
    #expect(responseBeforeReset.code == 200)
    #expect(responseBeforeReset.message == "stubbed response")
    
    // Reset stubs
    apiClient = apiClient.reset()
    await xctAssertThrowsErrorAsync(try await apiClient.sendRequest(spec)) { error in
      #expect(error.localizedDescription.contains("Platform.NetworkError"))
    }
  }

  @Test
  func testMultipleStubs() async throws {
    // Arrange
    let baseURL = URL(string: "https://example.com")!
    var apiClient = APIClient(baseURL: baseURL)
    let firstJSON = """
        {
            "message": "first response",
            "code": 200
        }
        """
    let secondJSON = """
        {
            "message": "second response",
            "code": 200
        }
        """
    apiClient = apiClient.stub(json: firstJSON, code: 200, endpoint: "/test-endpoint")
    apiClient = apiClient.stub(json: secondJSON, code: 200, endpoint: "/test-endpoint")
    let spec = TestAPISpecification()
    
    // Act
    let firstResponse = try await apiClient.sendRequest(spec) as! TestResponse
    let secondResponse = try await apiClient.sendRequest(spec) as! TestResponse
    
    // Assert
    #expect(firstResponse.message != secondResponse.message)
    #expect(firstResponse.message == "first response")
    #expect(secondResponse.message == "second response")
  }
  
  func xctAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure @escaping () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
  ) async {
    do {
      _ = try await expression()
      let msg = message()
      #expect(msg.isEmpty)
    } catch {
      errorHandler(error)
    }
  }
}
