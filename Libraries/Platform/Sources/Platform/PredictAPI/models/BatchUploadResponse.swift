//
//  BatchUploadResponse.swift
//  Platform
//
//  Created by Abubakar Oladeji on 27/03/2025.
//

public struct BatchUploadResponse: RequestModelConforms {
  // {"jobID":"51cb4f7d-166e-4044-ab06-f94a27ca1394","message":"Files uploaded successfully"}
  public let jobID: String
  public let message: String

  public static func == (lhs: BatchUploadResponse, rhs: BatchUploadResponse) -> Bool {
    return lhs.jobID == rhs.jobID &&
    lhs.message == rhs.message
  }
}
