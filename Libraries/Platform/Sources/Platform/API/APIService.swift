//
//  APIService.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public class APIService {
  private(set) var apiClient: APIClient
  
  public init(apiClient: APIClient) {
    self.apiClient = apiClient
  }
}
