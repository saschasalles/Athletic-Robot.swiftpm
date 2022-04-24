//
//  WorkoutSelectionViewModel.swift
//  
//
//  Created by Sascha Sallès on 23/04/2022.
//


final class WorkoutSelectionViewModel {

    private(set) lazy var title = "Now, it's your turn"

    private(set) lazy var subtitle =
"""
    After seeing me do squats and jumping jacks, it's now your turn.
    Here is a challenge that I prepared just for you!\n
    I'll time each of your squats and jumping jacks with my robot eyes, so you can see your score and improve.
"""
    
    private(set) lazy var warningText =
"""
This feature works only in portrait mode, also make sure the iPad remains static and stable for best results.
While this feature works on all iPad models, you'll be more comfortable using an iPad with an ultra-wide angle camera.
"""

    private(set) lazy var workout = Workout.thirstySeconds
}
