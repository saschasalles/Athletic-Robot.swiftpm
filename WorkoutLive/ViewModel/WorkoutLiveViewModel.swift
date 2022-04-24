//
//  WorkoutLiveViewModel.swift
//  
//
//  Created by Sascha Sallès on 17/04/2022.
//

import Foundation
import Combine
import Vision


protocol WorkoutLiveViewModelDescriptor {

    var robotViewModel: ScenePreviewViewModelDescriptor { get }
    
    var predictedWorkout: AnyPublisher<ClassifierPrediction, Never> { get }
    var globalProgressTimePublisher: AnyPublisher<Int, Never> { get }
    var workoutStatePublisher: AnyPublisher<WorkoutState, Never> { get }
    var currentAnimationTextPublisher: AnyPublisher<String, Never> { get }
    var challengeResultsPublisher: AnyPublisher<[DisplayableResult], Never> { get }

    func toggleWorkoutChallenge()
}

final class WorkoutLiveViewModel: WorkoutLiveViewModelDescriptor {
    init() {
        setupObservers()
    }

    // MARK: - Services

    private lazy var videoCaptureService: VideoCaptureServiceDescriptor = VideoCaptureService.shared
    private lazy var visionService: VisionServiceDescriptor = VisionService()
    private lazy var workoutDetectionService: WorkoutDetectionServiceDescriptor = WorkoutDetectionService()
    private lazy var audioService: AudioServiceDescriptor = AudioService.shared

    // MARK: - Exposed Properties

    private(set) lazy var predictedWorkout: AnyPublisher<ClassifierPrediction, Never> = predictionResultSubject.eraseToAnyPublisher()
    private(set) lazy var robotViewModel: ScenePreviewViewModelDescriptor = ScenePreviewViewModel(mode: .workout)

    private(set) lazy var globalProgressTimePublisher: AnyPublisher<Int, Never> = globalProgressTimeSubject.eraseToAnyPublisher()

    private(set) lazy var currentAnimationTextPublisher: AnyPublisher<String, Never> = currentAnimationTextSubject.eraseToAnyPublisher()
    private(set) lazy var workoutStatePublisher: AnyPublisher<WorkoutState, Never> = workoutStateSubject.eraseToAnyPublisher()
    private(set) lazy var challengeResultsPublisher: AnyPublisher<[DisplayableResult], Never> = challengeResultsSubject.eraseToAnyPublisher()



    // MARK: - Exposed methods

    func stopMusic() {
        audioService.pausePlayer()
    }

    func toggleWorkoutChallenge() {
        if workoutStateSubject.value != .inactive {
            workoutStateSubject.send(.inactive)
        } else {
            workoutStateSubject.send(.setup)
        }

        globalProgressTimeSubject.send(0)
    }

    // MARK: - Private Properties

    private var subscriptions = Set<AnyCancellable>()
    private var videoAnalyseSubscription = Set<AnyCancellable>()


    private lazy var predictionResultSubject = PassthroughSubject<ClassifierPrediction, Never>()

    private lazy var currentBodyObservation = PassthroughSubject<VNHumanBodyPoseObservation?, Never>()
    private lazy var globalTimerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private lazy var globalProgressTimeSubject = CurrentValueSubject<Int, Never>(0)

    private lazy var workoutStateSubject = CurrentValueSubject<WorkoutState, Never>(.inactive)

    private lazy var globalWorkoutDuration = 40 // 10 sec countdown + 30 sec workout

    private lazy var workoutFlow: [Range<Int> : AnimationKind?] = [
        0..<10 : nil,
        10..<20: .squat(.lower),
        20..<30 : .jumpingJack,
        30..<globalWorkoutDuration : .squat(.lower)
    ]

    private lazy var currentAnimationTextSubject = CurrentValueSubject<String, Never>(AnimationKind.squat(.lower).displayWorkoutString)
    private lazy var challengeResultsSubject = CurrentValueSubject<[DisplayableResult], Never>([])

    private var detectedPostures = [String: Int]()

    func setupObservers() {
        // 1st Step
        // I get the video stream from videoCapture Service
        // Then I perform a vision human body request
        videoCaptureService
            .videoDataBufferPublisher
//            .compactMap { [weak self] buffer in
//                self?.visionService.transformBufferIntoCGImage(from: buffer)
//            }
            .tryMap { [weak self] cmBuffer -> [VNHumanBodyPoseObservation]? in
                let postures = try self?.visionService.detectBodyPosture(from: cmBuffer)
                return postures
            }
            .mapError { $0 as? VisionError ?? .emptyResults }
            .compactMap { $0 }
            .compactMap { $0.first } // Getting the top first result
//            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error): print(error)
                    case .finished: return
                    }
                },
                receiveValue: { [weak self] observations in
                    self?.currentBodyObservation.send(observations)
                })
            .store(in: &subscriptions)


        // Increments count, end when it reach 40

        globalTimerPublisher
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                if self.workoutStateSubject.value != .inactive {
                    let currentTimeValue = self.globalProgressTimeSubject.value
                    if currentTimeValue < 40 {
                        self.globalProgressTimeSubject.send(currentTimeValue + 1)
                    } else if currentTimeValue == 40 {
                        self.endWorkout()
                    }
                }
            }
            .store(in: &subscriptions)

        globalTimerPublisher
            .sink { [weak self] _ in
                guard let `self` = self else { return }
                if self.workoutStateSubject.value != .ended {
                    let currentTimeValue = self.globalProgressTimeSubject.value
                    self.performChallengeFlow(from: currentTimeValue)
                }
            }
            .store(in: &subscriptions)
    }

    private func endWorkout() {
        workoutStateSubject.send(.ended)
        globalProgressTimeSubject.send(0)
        stopVideoAnalyse()
        sendResults()
    }

    private func resetWorkout() {
        workoutStateSubject.send(.inactive)
        globalProgressTimeSubject.send(0)
        clearResults()
    }

    private func performChallengeFlow(from currentTime: Int) {
        workoutFlow.forEach { range, animation in
            if range.contains(currentTime) {
                if let animation = animation {
                    workoutStateSubject.send(.started)
                    if workoutStateSubject.value == .started {
                        launchVideoAnalyse()
                        robotViewModel.performRobotAnimation(ofKind: animation)
                        currentAnimationTextSubject.send(animation.displayWorkoutString)
                    }
                }
            }
        }
    }

    private func launchVideoAnalyse() {
        // When currentBodyObservation is trigged
        // I perform the MLRequest from the Vision Request
        currentBodyObservation
            .compactMap { [weak self] observation -> MLMultiArray? in
                guard let currentObservation = observation else { return nil }
                return self?.visionService.getMultiArray(from: currentObservation)
            }
            .scan([MLMultiArray?](), { [weak self] previousWindow, multiArray in
                guard let `self` = self else { return [] }
                return self.workoutDetectionService.collectWindow(previousWindow: previousWindow, multiArray: multiArray)
            })
            .filter { [weak self] currentWindow in
                guard let `self` = self else { return false }
                return self.workoutDetectionService.gateWindow(currentWindow)
            }
            .map { [weak self] currentWindow in
                self?.workoutDetectionService.performPrediction(from: currentWindow)
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] predictionResult in
                guard let prediction = predictionResult else { return }
                self?.predictionResultSubject.send(prediction.0)

                if let workoutPrediction = prediction.0 as? WorkoutClassifierPrediction {
//                    print("Workout Prediction", workoutPrediction, prediction.1)
                    
                    let postureAccumulator = (self?.detectedPostures[workoutPrediction.label] ?? 0) + prediction.1
//                    print(postureAccumulator)
//                    print("PostureAccumulator", workoutPrediction, prediction.1)
                    self?.detectedPostures[workoutPrediction.label] = postureAccumulator
                }
            }

            .store(in: &videoAnalyseSubscription)
    }

    private func stopVideoAnalyse() {
        videoAnalyseSubscription.removeAll()
    }

    private func sendResults() {
        let sortedDetectedPostures = detectedPostures.sorted(by: { $0.value > $1.value })
        let totalFrames = sortedDetectedPostures.map { $0.value }.reduce(0, { $0 + $1 })

        let displayableResults: [DisplayableResult] = sortedDetectedPostures.map { key, value in
            let percent = (Double(value) * 100.0) / Double(totalFrames)
            let estimatedDuration = (percent * Double(globalWorkoutDuration - 10)) / 100.0

            let displayableResult = DisplayableResult(label: key,
                                                      duration: estimatedDuration,
                                                      percentageForSession: percent)
            return displayableResult
        }

        challengeResultsSubject.send(displayableResults)
    }

    private func clearResults() {
        detectedPostures.removeAll()
        challengeResultsSubject.send([])
    }

}
