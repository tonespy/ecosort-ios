//
//  PredictAPISpec.swift
//  Platform
//
//  Created by Abubakar Oladeji on 06/02/2025.
//

import Foundation

public enum PredictAPISpec: APIClient.APISpecification {
  case config
  case imagePredict(image: Data)
  case videoPredict(video: Data)
  
  public var endpoint: String {
    switch self {
    case .config:
      return "/v1/predict/config"
    case .imagePredict:
      return "/v1/predict/image"
    case .videoPredict:
      return "/v1/predict/video"
    }
  }
  
  public var method: APIClient.HttpMethod {
    switch self {
    case .config:
      return .get
    case .imagePredict:
      return .post
    case .videoPredict:
      return .post
    }
  }
  
  public var body: Data? {
    return nil
  }
  
  public var returnType: DecodableType.Type {
    return PredictionConfig.self
  }
}
