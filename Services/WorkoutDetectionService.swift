//
//  WorkoutDetectionService.swift
//  
//
//  Created by Sascha Sallès on 19/04/2022.
//

import Foundation
import CoreML

protocol WorkoutDetectionServiceDescriptor {
    func performPrediction(from window: [MLMultiArray?]) -> (ClassifierPrediction, Int)
    func collectWindow(previousWindow: [MLMultiArray?], multiArray: MLMultiArray?) -> [MLMultiArray?]
    func gateWindow(_ currentWindow: [MLMultiArray?]) -> Bool
}

final class WorkoutDetectionService: WorkoutDetectionServiceDescriptor {
    static private(set) var frameRate: Double = 30.0

    private let defaultConfiguration = MLModelConfiguration()

    private lazy var workoutClassifier: WorkoutClassifier = {
        guard let workoutClassifier = try? WorkoutClassifier(configuration: defaultConfiguration) else {
            fatalError("Failed to init Workout Classifier")
        }
    
        return workoutClassifier
    }()

    private var predictionWindowSize: Int { getPredictionWindowSize() }
    private let windowStride = 10

    private func getPredictionWindowSize() -> Int {
        let modelDescription = workoutClassifier.model.modelDescription

        let modelInputs = modelDescription.inputDescriptionsByName

        guard let input = modelInputs.first?.value,
              input.type == .multiArray,
              let multiArrayConstraint = input.multiArrayConstraint else {
            fatalError("Incorrect input format")
        }

        let dimensions = multiArrayConstraint.shape

        guard let firstDimension = dimensions.first,
                dimensions.count == 3 else {
            fatalError("The model's input multiarray must be 3 dimensions.")
        }

        let windowSize = Int(truncating: firstDimension)
        return windowSize
    }

    func performPrediction(from window: [MLMultiArray?]) -> (ClassifierPrediction, Int) {
        var poses = 0

        let filledWindow: [MLMultiArray] = window.map { multiArray in
            if let multiArray = multiArray {
                poses += 1
                return multiArray
            } else {
                let paddedArray = padMultiArrayWithZero(from: [1, 3, 18])
                return paddedArray
            }
        }

        let threshold = predictionWindowSize * 60 / 100

        guard poses >= threshold else { return (AppPrediction.noPersonPrediction, windowStride) }

        let mergedWindow = MLMultiArray(concatenating: filledWindow,
                                        axis: 0,
                                        dataType: .float)
        do {
            let predictionOutput = try workoutClassifier.prediction(poses: mergedWindow)
            let detectedWorkout = WorkoutClassifier.Label(predictionOutput.label)

            guard let confidence = predictionOutput.labelProbabilities[predictionOutput.label] else {
                fatalError("Can't have a confidence value")
            }

            let prediction = WorkoutClassifierPrediction(label: detectedWorkout.rawValue, confidence: confidence)
            let minimumConfidenceThreshold = 0.6
            let lowConfidence = prediction.confidence < minimumConfidenceThreshold

            return (lowConfidence ? AppPrediction.lowConfidencePrediction : prediction, windowStride)
        } catch {
            fatalError("Workout classifier prediction failed with error: \(error)")
        }
    }

    func collectWindow(previousWindow: [MLMultiArray?], multiArray: MLMultiArray?) -> [MLMultiArray?] {
        var currentWindow = previousWindow

        if previousWindow.count == predictionWindowSize {
            currentWindow.removeFirst(windowStride)
        }

        currentWindow.append(multiArray)

        return currentWindow
    }

    func gateWindow(_ currentWindow: [MLMultiArray?]) -> Bool {
        return currentWindow.count == predictionWindowSize
    }

    private func padMultiArrayWithZero(from shape: [Int]) -> MLMultiArray {
        guard let array = try? MLMultiArray(shape: shape as [NSNumber], dataType: .double),
              let pointer = try? UnsafeMutableBufferPointer<Double>(array)
        else {
            fatalError("Failed to create MLMultiArray")
        }

        pointer.initialize(repeating: 0.0)
        return array
    }
}
