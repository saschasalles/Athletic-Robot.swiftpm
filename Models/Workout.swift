//
//  Workout.swift
//  
//
//  Created by Sascha Sallès on 23/04/2022.
//

import Foundation
import SwiftUI

enum WorkoutState {
    case inactive
    case setup
    case started
    case ended
}

struct Workout {
    let title: String
    let instructions: [String]
    let presentationImageTitle: String
    let level: String
    let levelColor: Color

    static let thirstySeconds = Workout(title: "Thirsty Seconds",
                                        instructions: [
                                            "10 Seconds of Squats 🦵",
                                            "10 Seconds of Jumping Jack 🙆‍♂️",
                                            "10 Seconds of Squats 🦵"
                                        ],
                                        presentationImageTitle: "TimTop",
                                        level: "Easy",
                                        levelColor: .green)
}
