//
//  URLRequest+Extenstion.swift
//  Platform
//
//  Created by Abubakar Oladeji on 01/12/2024.
//

import Foundation

public extension URLRequest {
  var customDescription: String {
    var printableDescription = ""
    
    if let method = self.httpMethod {
      printableDescription += method
    }
    if let urlString = self.url?.absoluteString {
      printableDescription += " " + urlString
    }
    if let headers = self.allHTTPHeaderFields, !headers.isEmpty {
      let printableHeaders = headers.map {
        let value = $0.key.contains("X-API-Key") ? "******" : $0.value
        return "\($0.key): \(value)"
      }
      printableDescription += "\\nHeaders: \(printableHeaders)"
    }
    if let bodyData = self.httpBody,
       let body = String(data: bodyData, encoding: .utf8) {
      printableDescription += "\\nBody: \(body)"
    }
    
    return printableDescription.replacingOccurrences(of: "\\n", with: "\n")
  }
}

public extension URLResponse {
  var customDescription: String {
    var printableDescription = ""

    guard let current = self as? HTTPURLResponse else { return printableDescription }

    printableDescription += "\\nHTTP Status Code: \(current.statusCode)"
    printableDescription += "\\nContent-Length: \(current.expectedContentLength)"
    printableDescription += "\\nHeaders: \(current.allHeaderFields)"

    return printableDescription.replacingOccurrences(of: "\\n", with: "\n")
  }
}
