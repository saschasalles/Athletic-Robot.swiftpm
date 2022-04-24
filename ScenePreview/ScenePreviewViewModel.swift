//
//  SceneViewModelDescriptor.swift
//
//
//  Created by Sascha Sallès on 14/04/2022.
//

import Foundation
import Combine
import QuartzCore
import UIKit

protocol ScenePreviewViewModelDescriptor {
    var globalSceneURL: URL? { get }
    var isRobotRotating: AnyPublisher<Bool, Never> { get }
    var sceneBackground: Any { get }
    var currentMode: ScenePreviewMode { get }
    var performAnimationPublisher: AnyPublisher<AnimationKind, Never> { get }

    func toggleRobotRotation()
    func performRobotAnimation(ofKind kind: AnimationKind)
}

enum ScenePreviewMode {
    case presenting
    case workout
}

final class ScenePreviewViewModel: ScenePreviewViewModelDescriptor {

    // MARK: - Init
    init(mode: ScenePreviewMode) {
        self.currentMode = mode
        switch mode {
        case .presenting:
            sceneBackground = UIImage(named: "backgroundGradient") as Any
        case .workout:
            sceneBackground = UIColor.clear
        }
    }

    // MARK: - Exposed properties

    private(set) var sceneBackground: Any
    private(set) lazy var globalSceneURL: URL? = {
        guard let path = Bundle.main.path(forResource: "RobotScene", ofType: "scn") else { return nil }
        return URL(fileURLWithPath: path)
    }()

    private(set) lazy var performAnimationPublisher: AnyPublisher<AnimationKind, Never> = performAnimationSubject.eraseToAnyPublisher()

    private(set) lazy var isRobotRotating: AnyPublisher<Bool, Never> = isRobotRotatingSubject.eraseToAnyPublisher()

    // MARK: - Exposed Methods

    func toggleRobotRotation() {
        isRobotRotatingSubject.send(!isRobotRotatingSubject.value)
    }

    func performRobotAnimation(ofKind kind: AnimationKind) {
        performAnimationSubject.send(kind)
    }

    private(set) var currentMode: ScenePreviewMode

    // MARK: - Private
    private lazy var isRobotRotatingSubject = CurrentValueSubject<Bool, Never>(true)
    private lazy var performAnimationSubject = PassthroughSubject<AnimationKind, Never>()
    private var messagePlaybackTimer: CADisplayLink?

    
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



}
