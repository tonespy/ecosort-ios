//
//  APIAuthorizationMiddleware.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation
import SwiftUI

public struct APIAuthorizationMiddleware: APIClient.Middleware {
  public func intercept(_ request: URLRequest) async throws -> (URLRequest) {
    var requestCopy = request
    if let apiKey = Bundle.main.object(forInfoDictionaryKey: "API_REQ_KEY") as? String {
      requestCopy.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
    }
    return requestCopy
  }
  
  public init() {}
}
