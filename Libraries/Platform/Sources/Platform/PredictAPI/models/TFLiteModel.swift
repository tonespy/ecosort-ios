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
  public func runInference(inputData: Data) -> PredictionResult? {
    do {
      let inputTensor = try interpreter.input(at: 0)
      print("Expected shape:", inputTensor.shape)

      try interpreter.copy(inputData, toInputAt: 0)
      try interpreter.invoke()
      let outputTensor = try interpreter.output(at: 0)

      guard
        let predictedClassIndex = predictedClassIndex(from: outputTensor.data),
        let predictedClass = supportedClasses.first(where: { $0.index == predictedClassIndex }) else {
        return nil
      }
      print("Predicted class index: \(predictedClassIndex), \(predictedClass)")

      let result = PredictionResult(
        classification: predictedClass,
        data: inputData
      )
      return result
    } catch {
      print("Error during inference: \(error)")
      return nil
    }
  }

  public func runBatchInference(inputData: [Data]) async -> [PredictionResult] {
    await withCheckedContinuation { continuation in
      DispatchQueue.global(qos: .userInitiated).async {
        var outputs: [PredictionResult] = []
        for data in inputData {
          if let result = self.runInference(inputData: data) {
            outputs.append(result)
          } else {
            outputs.append(
              PredictionResult(
                classification: PredictionClasses(
                  index: -1,
                  name: "Unknown",
                  readableName: "Unknown",
                  description: "Unknown"
                ),
                data: data
              )
            )
          }
        }

        let finalOutputs = outputs  // Capture outputs immutably
        DispatchQueue.main.async {
          continuation.resume(returning: finalOutputs)
        }
      }
    }
  }

  public func runBatchInference(inputData: [Data], completion: @escaping ([PredictionResult]) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
      var outputs: [PredictionResult] = []
      for data in inputData {
        if let result = self.runInference(inputData: data) {
          outputs.append(result)
        } else {
          outputs.append(
            PredictionResult(
              classification: PredictionClasses(
                index: -1,
                name: "Unknwon",
                readableName: "Unknown",
                description: "Unknown"
              ),
              data: data
            )
          )
        }
      }
      DispatchQueue.main.async {
        completion(outputs)
      }
    }
  }
}
