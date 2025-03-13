//
//  APIClient+Middleware.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public extension APIClient {
  protocol Middleware {
    func intercept(_ request: URLRequest) async throws -> (URLRequest)
  }
}
