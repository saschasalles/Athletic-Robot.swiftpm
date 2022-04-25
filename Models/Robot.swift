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
        "I am delighted to meet you !",
        "My name is Tim Coach and I will be your personal trainer for the next few minutes",
        "Today we are going to do a little physical exercise and we are going to do squats and jumping jacks.",
        "Let me show you all this in AR"
    ]

    let motivationSentences: [String]
    static let shared = Robot(motivationSentences: ["You can do it","Keep it!"])
}
