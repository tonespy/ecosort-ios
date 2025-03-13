//
//  APIClient.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public struct APIClient {
  private var baseURL: URL
  private var urlSession: URLSession
  private(set) var middlewares: [any Middleware]
  
  public init(
    baseURL: URL,
    middleware: [any Middleware] = [],
    urlSession: URLSession = .shared
  ) {
    self.baseURL = baseURL
    self.middlewares = middleware
    self.urlSession = urlSession
  }
  
  public func sendRequest(_ apiSpec: APISpecification) async throws -> DecodableType {
    guard let url = URL(string: baseURL.absoluteString + apiSpec.endpoint) else {
      throw NetworkError.invalidURL
    }
    
    var request = URLRequest(
      url: url,
      cachePolicy: .useProtocolCachePolicy,
      timeoutInterval: TimeInterval(floatLiteral: 30.0)
    )
    request.httpMethod = apiSpec.method.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = apiSpec.body
    
    // apply the middlewares
    var updatedRequest = request
    for middleware in middlewares {
      let tempRequest = updatedRequest
      updatedRequest = try await wrapCatchingErrors {
        try await middleware.intercept(
          tempRequest
        )
      }
    }
    
    var responseData: Data? = nil
    do {
      let (data, response) = try await urlSession.data(for: updatedRequest)
      retrieveLogMiddleware()?.logResponse(response, data: data)
      try handleResponse(data: data, response: response)
      responseData = data
    } catch {
      throw error
    }
    
    guard let responseData else {
      throw NetworkError.dataConversionFailure
    }
    
    let decoder = JSONDecoder()
    do {
      let decodedData = try decoder.decode(
        apiSpec.returnType,
        from: responseData
      )
      return decodedData
    } catch let error as DecodingError {
      throw error
    } catch {
      throw NetworkError.dataConversionFailure
    }
  }

  public func retrieveLogMiddleware() -> APILoggingMiddleware? {
    let findLogMiddleware = middlewares.first {
      $0 is APILoggingMiddleware
    }

    guard let loggingMiddleware = findLogMiddleware as? APILoggingMiddleware else {
      return nil
    }
    return loggingMiddleware
  }

  public func downloadFile(from endpoint: String) async throws -> URL {
    guard let url = URL(string: baseURL.absoluteString + endpoint) else {
      throw NetworkError.invalidURL
    }
    
    let (tempFileURL, response) = try await urlSession.download(from: url)
    
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
      throw NetworkError.requestFailed(statusCode: (response as? HTTPURLResponse)?.statusCode ?? -1)
    }
    
    return tempFileURL // Returns the local file URL
  }
  
  private func handleResponse(data: Data, response: URLResponse) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
      throw NetworkError.invalidResponse
    }
    
    guard (200...299).contains(httpResponse.statusCode) else {
      throw NetworkError.requestFailed(statusCode: httpResponse.statusCode)
    }
  }
  
  private func wrapCatchingErrors<R>(work: () async throws -> R) async throws -> R {
    do {
      return try await work()
    } catch {
      throw error
    }
  }
  
  public func copy(session newSession: URLSession) -> APIClient {
    var apiClientCopy = self
    apiClientCopy.urlSession = newSession
    return apiClientCopy
  }
}

