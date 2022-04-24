//
//  ClassifierPrediction.swift
//  
//
//  Created by Sascha Sallès on 19/04/2022.
//

import Foundation


protocol ClassifierPrediction {
    var label: String { get }
    var confidence: Double? { get }
}

extension ClassifierPrediction {
    var confidence: Double? { nil }
}

struct WorkoutClassifierPrediction: ClassifierPrediction {
    init(label: String, confidence: Double) {
        self.label = label
        self.confidence = confidence
    }

    let label: String
    let confidence: Double

    var confidenceDisplayString: String { String(format: "%2.0f %%", confidence * 100) }
}

struct AppPrediction: ClassifierPrediction {
    let label: String

    private init(label: String) {
        self.label = label
    }

    static let noPersonPrediction = AppPrediction(label: "No Person 👀")
    static let startingPrediction = AppPrediction(label: "Starting...\nPlace your entire body in the screen")
    static let lowConfidencePrediction = AppPrediction(label: "???? 🙄")
}

struct DisplayableResult: Hashable, Identifiable {
    let id = UUID()
    let label: String
    let duration: Double
    let percentageForSession: Double

    var displayableDuration: String { String(format: "%0.1fs", duration) }
    var displayablePercentage: String { String(format: "%2.1f %%", percentageForSession) }

}
