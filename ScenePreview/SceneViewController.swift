//
//  SceneViewController.swift
//  
//
//  Created by Sascha Sallès on 14/04/2022.
//

import Foundation
import SceneKit
import AVFoundation
import UIKit
import Combine

enum SceneKitError: Error {
    case unableToLoad
    case noCamera
}

final class SceneViewController: BaseRobotSceneViewController {

    // MARK: - Init

    init(with viewModel: ScenePreviewViewModelDescriptor) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        setupUI()
        setupObservers()
    }

    // MARK: - Private Properties

    private let viewModel: ScenePreviewViewModelDescriptor

    private var subscriptions = Set<AnyCancellable>()

    private lazy var sceneView: SCNView = {

        let sceneView = SCNView(frame: .zero, options: nil)
        sceneView.antialiasingMode = .multisampling4X

        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true

        sceneView.contentMode = .scaleAspectFit
        sceneView.rendersContinuously = true

        return sceneView
    }()

    // MARK: - Private Methods

    private func setupObservers() {
        viewModel.isRobotRotating
            .sink { [weak self] shouldPerformRotation in
                self?.rotateRobot(shouldStop: !shouldPerformRotation)
            }
            .store(in: &subscriptions)

        viewModel.performAnimationPublisher
            .sink { [weak self] animation in
                switch animation {
                case .jumpingJack:          self?.performJumpingJackAnimation()
                case .squat(let squatKind): self?.performSquatAnimation(ofKind: squatKind)
                }
            }
            .store(in: &subscriptions)
    }

    private func configureScene() throws -> SCNScene  {
        guard let url = viewModel.globalSceneURL else {
            throw SceneKitError.unableToLoad
        }
        let scene = try SCNScene(url: url)

        view.backgroundColor = .clear
        sceneView.backgroundColor = .clear
        scene.background.contents = viewModel.sceneBackground
        if viewModel.currentMode == .workout {
            scene.rootNode.scale = SCNVector3(0.9, 0.9, 0.9)
        }
        return scene
    }

    private func setupUI() {
        view.addSubview(sceneView)

        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])

        sceneView.scene = try? configureScene()
    }

    private func rotateRobot(shouldStop: Bool = false) {
        guard viewModel.currentMode != .workout else { return }
        guard let rootNode = sceneView.scene?.rootNode else { return }

        if shouldStop {
            rootNode.removeAction(forKey: "foreverRotation")
            return
        }

        let rotation = SCNAction.rotateBy(x: 0, y: 0.13, z: 0, duration: 1)
        let foreverRotation = SCNAction.repeatForever(rotation)
        rootNode.runAction(foreverRotation, forKey: "foreverRotation")
    }


    private func performJumpingJackAnimation() {
        guard let rootNode = sceneView.scene?.rootNode,
              let globalBody = rootNode.childNode(withName: "Global", recursively: true),
              let rightArm = globalBody.childNode(withName: "GRArm", recursively: true),
              let rightShoulder = rightArm.childNode(withName: "RShoulderJoint", recursively: false),
              let leftArm = globalBody.childNode(withName: "GLArm", recursively: true),
              let leftShoulder = leftArm.childNode(withName: "LShoulderJoint", recursively: false),
              let rightLeg = globalBody.childNode(withName: "RLeg", recursively: true),
              let rightTopLeg = rightLeg.childNode(withName: "RTopLeg", recursively: false),
              let leftLeg = globalBody.childNode(withName: "LLeg", recursively: true),
              let leftTopLeg = leftLeg.childNode(withName: "LTopLeg", recursively: false)
        else { return }


        jumpingJackShoulderRotation(on: rightShoulder, duration: 0.3)
        jumpingJackShoulderRotation(on: leftShoulder, duration: 0.3)

        jumpingJackLegsRotation(on: rightTopLeg, duration: 0.3)
        jumpingJackLegsRotation(on: leftTopLeg, duration: 0.3)
        performLittleJump(on: globalBody, duration: 0.15)
    }

    private func performSquatAnimation(ofKind kind: SquatKind, duration: TimeInterval = 0.4) {

        guard let rootNode = sceneView.scene?.rootNode,
              let global = rootNode.childNode(withName: "Global", recursively: true),
              let rightArm = global.childNode(withName: "GRArm", recursively: true),
              let rightShoulder = rightArm.childNode(withName: "RShoulderJoint", recursively: false),
              let leftArm = global.childNode(withName: "GLArm", recursively: true),
              let leftShoulder = leftArm.childNode(withName: "LShoulderJoint", recursively: false),
              let rightLeg = global.childNode(withName: "RLeg", recursively: true),
              let rightTopLeg = rightLeg.childNode(withName: "RTopLeg", recursively: true),
              let rightKnee = rightTopLeg.childNode(withName: "GRKnee", recursively: true),
              let leftLeg = global.childNode(withName: "LLeg", recursively: true),
              let leftTopLeg = leftLeg.childNode(withName: "LTopLeg", recursively: true),
              let leftKnee = leftTopLeg.childNode(withName: "GLKnee", recursively: true),
              let globalBody = global.childNode(withName: "GBody", recursively: true),
              let globalHead = global.childNode(withName: "GHead", recursively: true)
        else { return }


        let rightShoulderRotationAnimation = squatShoulderRotation(on: rightShoulder,
                                                                   duration: duration)
        let leftShoulderRotationAnimation = squatShoulderRotation(on: leftShoulder,
                                                                  duration: duration)
        let globalBodyTranslateAnimation = squatTopBodyTranslate(ofKind: kind,
                                                                 on: globalBody,
                                                                 duration: duration)

        let rightShoulderTranslateAnimation = squatTopBodyTranslate(ofKind: kind,
                                                                    on: rightShoulder,
                                                                    duration: duration)
        let leftShoulderTranslateAnimation = squatTopBodyTranslate(ofKind: kind,
                                                                   on: leftShoulder,
                                                                   duration: duration)
        let globalHeadTranslateAnimation = squatTopBodyTranslate(ofKind: kind,
                                                                 on: globalHead,
                                                                 duration: duration)

        squatKneeRotation(ofKind: kind, on: leftKnee, duration: duration) { [weak self] in
            if let reversedAction = self?.squatKneeRotation(ofKind: kind, on: leftKnee, duration: duration, shouldRun: false).reversed() {
                leftKnee.runAction(reversedAction)
                globalBody.runAction(globalBodyTranslateAnimation.reversed())
                rightShoulder.runAction(rightShoulderTranslateAnimation.reversed())
                leftShoulder.runAction(leftShoulderTranslateAnimation.reversed())
                globalHead.runAction(globalHeadTranslateAnimation.reversed())
                rightShoulder.runAction(rightShoulderRotationAnimation.reversed())
                leftShoulder.runAction(leftShoulderRotationAnimation.reversed())
            }
        }

        squatKneeRotation(ofKind: kind, on: rightKnee, duration: duration) { [weak self] in
            if let reversedAction = self?.squatKneeRotation(ofKind: kind, on: rightKnee, duration: duration, shouldRun: false).reversed() {
                rightKnee.runAction(reversedAction)
            }
        }
    }

    


}
