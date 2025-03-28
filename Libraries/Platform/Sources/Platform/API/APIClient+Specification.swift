//
//  APIClient+Specification.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public extension APIClient {
  protocol APISpecification {
    var endpoint: String { get }
    var method: HttpMethod { get }
    var returnType: DecodableType.Type { get }
    var body: Data? { get }
    var bodyWithBoundary: [String: Data]? { get }
  }
  
  enum HttpMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
    case head = "HEAD"
    case options = "OPTIONS"
  }
}

public protocol DecodableType: Decodable { }
extension Array: DecodableType where Element: DecodableType {}
