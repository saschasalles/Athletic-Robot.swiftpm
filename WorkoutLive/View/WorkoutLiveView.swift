//
//  WorkoutLiveView.swift
//  
//
//  Created by Sascha Sallès on 23/04/2022.
//

// I was unable to block this specific screen rotation 🥲

import SwiftUI
import AVFAudio

struct WorkoutLiveView: View {
    private let viewModel: WorkoutLiveViewModelDescriptor = WorkoutLiveViewModel()
    @Environment(\.presentationMode) private var presentationMode
    @State private var currentWorkout = AppPrediction.startingPrediction.label
    @State private var workoutState: WorkoutState = .inactive
    @State private var progress: Float = 0.0
    @State private var globalSpentTime: Int = 0
    @State private var countDown: Int = 10
    @State private var currentAnimation: String = AnimationKind.squat(.lower).displayWorkoutString
    @State private var detectionResults = [DisplayableResult]()

    var body: some View {
        ZStack {
            LivePreviewView()
                .ignoresSafeArea()

            VStack(alignment: .trailing) {
                HeaderNavigationView(
                    navigationLeftButtonAction: {
                        presentationMode.wrappedValue.dismiss()
                    },
                    navigationRightContent: {
                        VStack {
                            if workoutState != .ended {
                                RoundedButton(title: workoutState != .inactive ? "Stop Challenge" : "Start Challenge",
                                              systemImage: workoutState != .inactive ? "stop.circle.fill" : "play.circle.fill",
                                              backgroundColor: workoutState != .inactive ? .red : .green) {
                                    viewModel.toggleWorkoutChallenge()
                                }
                            } else {
                                RoundedButton(title: "Well Done!",
                                              systemImage: "checkmark.circle.fill",
                                              backgroundColor: .yellow)
                            }
                        }
                    },
                    titleText: workoutState == .started ? $currentWorkout : .constant("Click Start☝️ Make Sport🙆‍♂️ Have Fun😎"))
                .padding(.vertical, 25)
                Spacer()

                if workoutState == .started {
                    VStack(spacing: 20) {
                        CircularProgressView(progress: $progress,
                                             displayText: $currentAnimation)
                        .frame(height: 200, alignment: .center)
                        ScenePreviewView(with: viewModel.robotViewModel)
                    }
                    .padding(30)
                    .frame(width: 340, height: 700)
                    .background(Material.ultraThin)
                    .cornerRadius(30, corners: [.topLeft])
                    .transition(.move(edge: .trailing))
                }
            }
            .ignoresSafeArea()

            if workoutState == .setup {
                DimmedView(opacity: 0.6) {
                    VStack(alignment: .center, spacing: 50) {
                        Text("\(countDown)")
                            .font(.system(size: 250,
                                          weight: .black,
                                          design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .frame(width: 400, height: 200, alignment: .center)

                        Text("Make sure your body fill the entire screen for accurate results ")
                            .font(.system(size: 70,
                                          weight: .bold,
                                          design: .default))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        HStack {
                            Spacer()
                            RoundedButton(title: "Stop Challenge",
                                          systemImage: "stop.circle.fill",
                                          backgroundColor: .red,
                                          action: { viewModel.toggleWorkoutChallenge() } )
                            Spacer()
                        }
                    }
                }
                .transition(.opacity)
                .ignoresSafeArea()
            }

            if workoutState == .ended {
                DimmedView(opacity: 0.7) {
                    VStack(alignment: .center) {

                        Text("Congratulation 👏🎉")
                            .font(.system(size: 70, weight: .black, design: .default))
                            .foregroundColor(.white)
                        
                        Text("Here are your results")
                            .font(.system(size: 60, weight: .heavy, design: .default))
                            .foregroundColor(.white)

                        Text("I detected your movements with my robot eyes.\nAnd sometimes I may squint and not see everything.\nIf that's the case, why don't you try a sports session again?")
                            .font(.headline)
                            .foregroundColor(.white)


                        HStack(spacing: 20) {
                            if detectionResults.isEmpty {
                                Text("No results found, retry ?")
                                    .font(.title)
                                    .bold()
                                    .foregroundColor(.orange)
                                    .padding()
                            } else {
                                ForEach(detectionResults) { result in
                                    VStack(alignment: .center) {
                                        Text(result.label)
                                            .bold()
                                        Text(result.displayablePercentage)
                                        Text(result.displayableDuration)
                                    }
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 200, height: 160)
                                    .background(LinearGradient(colors: [.accentColor, .orange],
                                                               startPoint: .topLeading,
                                                               endPoint: .bottomTrailing))
                                    .cornerRadius(24)
                                }
                            }

                        }
                        .padding()

                        HStack(spacing: 20) {
                            Button {
                                viewModel.toggleWorkoutChallenge()
                            } label: {
                                Label("Retry", systemImage: "arrow.counterclockwise")
                            }
                            .buttonStyle(WhiteButtonStyle())

                            Button {
                                // viewModel.goToHome()
                            } label: {
                                Label("Go back to home", systemImage: "house")
                            }
                            .buttonStyle(WhiteButtonStyle())
                        }
                    }
                }
                .ignoresSafeArea()
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onReceive(viewModel.predictedWorkout) { workout in
            let prefix = "You are doing:"
            switch workout {
            case let workoutPrediction as WorkoutClassifierPrediction:
                currentWorkout = "\(prefix) \(workoutPrediction.label)"
            case let appPrediction as AppPrediction:
                if appPrediction.label == AppPrediction.startingPrediction.label {
                    currentWorkout = appPrediction.label
                } else {
                    currentWorkout = "\(prefix) \(appPrediction.label)"
                }
            default: currentWorkout = AppPrediction.noPersonPrediction.label
            }
        }
        .onReceive(viewModel.globalProgressTimePublisher) { spentTime in
            let initialCountDown = 10
            countDown = initialCountDown - spentTime
            withAnimation {
                globalSpentTime = spentTime
                if globalSpentTime > 10 {
                    let progressThirsty = Float(((globalSpentTime - 10) * 100) / 30) / 100
                    progress = progressThirsty
                }
            }
        }
        .onReceive(viewModel.workoutStatePublisher) { state in
            withAnimation(.easeIn) {
                workoutState = state
            }
        }
        .onReceive(viewModel.currentAnimationTextPublisher) { animationText in
            withAnimation {
                currentAnimation = animationText
            }
        }
        .onReceive(viewModel.challengeResultsPublisher) { results in
            detectionResults = results
        }
    }
}
