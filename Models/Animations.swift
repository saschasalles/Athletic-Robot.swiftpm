//
//  Animations.swift
//  
//
//  Created by Sascha Sallès on 22/04/2022.
//

import Foundation

enum AnimationKind {
    case squat(SquatKind)
    case jumpingJack

    var stringValue: String {
        switch self {
        case .squat(.lower):
            return SquatKind.lower.rawValue
        case .squat(.upper):
            return SquatKind.upper.rawValue
        case .jumpingJack:
            return "Jumping Jack"
        }
    }

    var displayWorkoutString: String {
        switch self {
        case .squat(.lower):
            return "Squat"
        case .squat(.upper):
            return "Squat"
        case .jumpingJack:
            return "Jumping Jack"
        }
    }
}

enum SquatKind: String {
    case upper = "Upper Squat"
    case lower = "Lower Squat"
}
