//
//  APIError.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public enum NetworkError: Error, Equatable {
  case invalidURL
  case invalidResponse
  case dataConversionFailure
  case invalidData
  case invalidHTTPStatus(statusCode: Int)
  case requestFailed(statusCode: Int)
  case unknownError(message: String)
}
