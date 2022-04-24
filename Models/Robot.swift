//
//  Robot.swift
//  
//
//  Created by Sascha Sallès on 22/04/2022.
//

import Foundation

struct Robot: Identifiable {
    private init(motivationSentences: [String]) {
        self.motivationSentences = motivationSentences
    }

    let id = UUID()
    let introSentences: [String] = [
        "Hello my dear 😄",
        "Nice to meet you ! ",
        "I am Tim Coach, your personal trainer 💪 \nHere to serve you!",
        "Today we are going to learn how to make some Squats and Jumping Jacks",
        "Let's me show you this in AR"
    ]

    let motivationSentences: [String]
    static let shared = Robot(motivationSentences: ["You can do it","Keep it!"])
}
