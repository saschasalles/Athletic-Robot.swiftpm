//
//  WorkoutClassifier+Label.swift
//  
//
//  Created by Sascha Sallès on 19/04/2022.
//


extension WorkoutClassifier {
    enum Label: String, CaseIterable {
        case squats = "Squats"
        case jumpingJacks = "Jumping Jacks"
        case other = "Other"

        init(_ string: String) {
            guard let label = Label(rawValue: string) else {
                let typeName = String(reflecting: Label.self)
                fatalError("Add the `\(string)` label to the `\(typeName)` type.")
            }

            self = label
        }
    }
}

