//
//  File.swift
//  Platform
//
//  Created by Abubakar Oladeji on 18/02/2025.
//

import Foundation
import TensorFlowLiteSwift

public struct PredictionResult {
  public let classification: PredictionClasses
  public let data: Data

  init(classification: PredictionClasses, data: Data) {
    self.classification = classification
    self.data = data
  }
}

public enum TFLiteModelError: Error {
  case invalidClass
  case unknwownError(Error)

  public var errorInformation: String {
    switch self {
    case .invalidClass:
      return "Invalid classification provided."
    case .unknwownError(let error):
      return "\(error)"
    }
  }
}

public enum TFLiteModelResult {
  case success(PredictionResult)
  case failure(TFLiteModelError)
}

public class TFLiteModel {
  private var interpreter: Interpreter

  private var supportedClasses: [PredictionClasses] {
    return UserDefaults.standard.predictionConfiguration?.classes ?? []
  }

  public init?(modelPath: String) {
    do {
      // Create the interpreter with the model path.
      interpreter = try Interpreter(modelPath: modelPath)
      try interpreter.allocateTensors()
    } catch {
      print("Failed to create the interpreter: \(error)")
      return nil
    }
  }

  // Helper function to convert Data to [Float32]
  func floatArray(from data: Data) -> [Float32] {
    let count = data.count / MemoryLayout<Float32>.size
    return data.withUnsafeBytes { buffer in
      // Bind the memory to Float32 and create an array of that count.
      Array(buffer.bindMemory(to: Float32.self)[0..<count])
    }
  }

  // Function to get the predicted class index from the output data.
  func predictedClassIndex(from outputData: Data) -> Int? {
    let probabilities = floatArray(from: outputData)
    guard probabilities.count == supportedClasses.count else {
      print("Mismatch in expected count, got \(probabilities.count) probabilities.")
      return nil
    }
    // Find the index of the maximum probability
    let maxIndex = probabilities.enumerated().max { a, b in a.element < b.element }?.offset
    return maxIndex
  }

  /// Runs inference on the given input data.
  /// Adjust the input and output processing as needed for your model.
  public func runInference(inputData: Data) -> TFLiteModelResult {
    do {
//      let inputTensor = try interpreter.input(at: 0)
//      print("Expected shape:", inputTensor.shape)

      try interpreter.copy(inputData, toInputAt: 0)
      try interpreter.invoke()
      let outputTensor = try interpreter.output(at: 0)

      guard
        let predictedClassIndex = predictedClassIndex(from: outputTensor.data),
        let predictedClass = supportedClasses.first(where: { $0.index == predictedClassIndex }) else {
        return .failure(TFLiteModelError.invalidClass)
      }
//      print("Predicted class index: \(predictedClassIndex), \(predictedClass)")

      let result = PredictionResult(
        classification: predictedClass,
        data: inputData
      )
      return .success(result)
    } catch {
      print("Error during inference: \(error)")
      return .failure(TFLiteModelError.unknwownError(error))
    }
  }
}
