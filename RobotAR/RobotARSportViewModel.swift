//
//  RobotARViewModel.swift
//  
//
//  Created by Sascha Sallès on 21/04/2022.
//

import Combine
import Foundation
import QuartzCore

protocol RobotARSportViewModelDescriptor {
    var globalSceneURL: URL? { get }
    var focusSceneURL: URL? { get }

    var performAnimationPublisher: AnyPublisher<AnimationKind, Never> { get }
    var performResetARSessionPublisher: AnyPublisher<(), Never> { get }
    var performPauseARSessionPublisher: AnyPublisher<(), Never> { get }
    var performToggleSceneStatsPublisher: AnyPublisher<Bool, Never> { get }
    var isMusicPlayingPublisher: AnyPublisher<Bool, Never> { get }
    var currentAnimationSentencePublisher: AnyPublisher<String, Never> { get }

    var currentInfoText: CurrentValueSubject<String, Never> { get }
    var isRobotNodeVisible: CurrentValueSubject<Bool, Never> { get }

    func performRobotAnimation(ofKind kind: AnimationKind)
    func sportOverMusic()
    func resetARSession()
    func toggleSceneStats()
    func viewDidDisappear()

    func pauseARSession()
    func toggleIsMusicMuted()
    func resetMusic()
}

final class RobotARSportViewModel: RobotARSportViewModelDescriptor {

    required init() {
        guard let fileURL = Song.softSong.url else { return }
        AudioService.shared.setupMusic(from: fileURL)
        setupObservers()
    }

    // MARK: - Exposed Properties

    private(set) lazy var globalSceneURL: URL? = {
        guard let path = Bundle.main.path(forResource: "RobotScene", ofType: "scn") else { return nil }
        return URL(fileURLWithPath: path)
    }()

    private(set) lazy var focusSceneURL: URL? = {
        guard let path = Bundle.main.path(forResource: "FocusScene", ofType: "scn") else { return nil }
        return URL(fileURLWithPath: path)
    }()

    private(set) lazy var isMusicPlayingPublisher: AnyPublisher<Bool, Never> =
    isMusicPlayingSubject.eraseToAnyPublisher()

    private(set) lazy var currentAnimationSentencePublisher: AnyPublisher<String, Never> = currentAnimationSentenceSubject.eraseToAnyPublisher()

    private(set) lazy var performAnimationPublisher: AnyPublisher<AnimationKind, Never> = performAnimationSubject.eraseToAnyPublisher()

    private(set) lazy var performResetARSessionPublisher: AnyPublisher<(), Never> = performResetARSessionSubject.eraseToAnyPublisher()

    private(set) lazy var performPauseARSessionPublisher: AnyPublisher<(), Never> =
    performPauseARSessionSubject.eraseToAnyPublisher()

    private(set) lazy var performToggleSceneStatsPublisher: AnyPublisher<Bool, Never> = performToggleSceneStatsSubject.eraseToAnyPublisher()

    private(set) lazy var currentInfoText = CurrentValueSubject<String, Never>("Tracking")
    private(set) lazy var isRobotNodeVisible = CurrentValueSubject<Bool, Never>(false)




    // MARK: - Exposed Methods

    func sportOverMusic() {
        let audioService = AudioService.shared

        if audioService.isPlayingValue {
            audioService.pausePlayer()
            currentAnimationSentenceSubject.send(initialAnimationSentence)
        } else {
            currentAnimationSentenceSubject.send("Ohh that's so cool, this is my favorite song! Let me practice on it")
            audioService.playAudio()
            launchSynchronizedSportSequence()
        }
    }

    func toggleIsMusicMuted() {
        let audioService = AudioService.shared
        guard let isMuted = audioService.isMuted else { return }
        isMuted ? audioService.unmute() : audioService.mute()
    }

    func resetMusic() {
        // prepare the player in case of reinit of robot node
        guard let fileURL = Song.softSong.url else { return }
        AudioService.shared.setupMusic(from: fileURL)
    }

    func viewDidDisappear() {
        resetMusic()
    }

    func performRobotAnimation(ofKind kind: AnimationKind) {
        getAssociatedAnimationSentence(forAnimation: kind)
        performAnimationSubject.send(kind)
    }

    func resetARSession() {
        performResetARSessionSubject.send(())
    }


    func pauseARSession() {
        performPauseARSessionSubject.send(())
    }


    func toggleSceneStats() {
        performToggleSceneStatsSubject.send(!performToggleSceneStatsSubject.value)
    }

    // MARK: - Private

    private var subscriptions = Set<AnyCancellable>()
    private lazy var performAnimationSubject = PassthroughSubject<AnimationKind, Never>()
    private lazy var performResetARSessionSubject = PassthroughSubject<(), Never>()
    private lazy var performPauseARSessionSubject = PassthroughSubject<(), Never>()
    private lazy var performToggleSceneStatsSubject = CurrentValueSubject<Bool, Never>(false)
    private lazy var isMusicPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private lazy var currentAnimationSentenceSubject = CurrentValueSubject<String, Never>(initialAnimationSentence)
    private var initialAnimationSentence = "Choose an action to get some info 👇"

    private var messagePlaybackTimer: CADisplayLink?

    private func setupObservers() {
        isRobotNodeVisible
            .eraseToAnyPublisher()
            .delay(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] isVisible in
                if !isVisible { self?.resetMusic() }
            }
            .store(in: &subscriptions)

        AudioService.shared.isPlayingPublisher
            .sink { [weak self] isPlaying in
                guard let `self` = self else { return }
                self.isMusicPlayingSubject.send(isPlaying)
                if !isPlaying {
                    self.currentAnimationSentenceSubject.send(self.initialAnimationSentence)
                }
            }
            .store(in: &subscriptions)
    }


    @objc private func performRobotAction() {
        let triggerPoints = Song.softSong.triggerPoints
        guard let currentTime = AudioService.shared.currentTime else { return }
        let floatingTime = (currentTime * 10).rounded() / 10

        triggerPoints.forEach { timePoint, animation in
            if floatingTime == timePoint {
                performRobotAnimation(ofKind: animation)
            }
        }

    }

    private func launchSynchronizedSportSequence() {
        messagePlaybackTimer?.invalidate()
        messagePlaybackTimer = nil

        messagePlaybackTimer = CADisplayLink(target: self, selector: #selector(performRobotAction))
        messagePlaybackTimer?.add(to: RunLoop.main, forMode: .common)
    }

    private func getAssociatedAnimationSentence(forAnimation animation: AnimationKind) {
        if !AudioService.shared.isPlayingValue {
            switch animation {
            case .squat(let squatKind):
                switch squatKind {
                case .upper:
                    currentAnimationSentenceSubject.send("The upper squat is the easiest form of squat. Perfect for begginers 😎")
                case .lower:
                    currentAnimationSentenceSubject.send("This kind of squat is more efficient.\nPerfect for properly working the glutes.\nBe sure to warm up well your knees beforehand")
                }
            case .jumpingJack:
                currentAnimationSentenceSubject.send("Jumping jacks work the whole body, plus all the major lower body muscles are used.")
            }
        }
    }
}
