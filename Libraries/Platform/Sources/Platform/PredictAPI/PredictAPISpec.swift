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
  case batchImagePredict(images: [String: Data])
  case videoPredict(video: Data)
  
  public var endpoint: String {
    switch self {
    case .config:
      return "/v1/predict/config"
    case .imagePredict:
      return "/v1/predict/"
    case .batchImagePredict:
      return "/v1/predict/batch"
    case .videoPredict:
      return "/v1/predict/video"
    }
  }
  
  public var method: APIClient.HttpMethod {
    switch self {
    case .config:
      return .get
    case .imagePredict, .videoPredict, .batchImagePredict:
      return .post
    }
  }
  
  public var body: Data? {
    return nil
  }

  public var bodyWithBoundary: [String : Data]? {
    switch self {
    case .batchImagePredict(let images):
      let boundary = UUID().uuidString
      let requestBody = images.createMultipartBody(
        boundary: boundary,
        fieldName: "files"
      )
      return [boundary: requestBody]
    default:
      return nil
    }
  }

  public var returnType: DecodableType.Type {
    switch self {
    case .batchImagePredict:
      return BatchUploadResponse.self
    default:
      return PredictionConfig.self
    }
  }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value == Data {
  /// Creates a multipart/form-data body from an array of file dictionaries.
  ///
  /// - Parameters:
  ///   - boundary: The boundary string used to separate parts.
  ///   - fieldName: The form field name to use for each file.
  ///   - mimeType: The MIME type for the files (default is "image/jpeg").
  /// - Returns: A Data object representing the complete multipart/form-data body.
  func createMultipartBody(boundary: String, fieldName: String, mimeType: String = "image/jpeg") -> Data {
    var body = Data()

    for (fileName, fileData) in self {
      // Append the boundary.
      body.append("--\(boundary)\r\n".data(using: .utf8)!)
      // Append the Content-Disposition header with the provided field name and file name.
      body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
      // Append the Content-Type header.
      body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
      // Append the actual file data.
      body.append(fileData)
      body.append("\r\n".data(using: .utf8)!)
    }

    // Append the closing boundary.
    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
    return body
  }
}
