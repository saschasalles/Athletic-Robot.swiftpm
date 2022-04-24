//
//  RobotARSportViewController.swift
//  
//
//  Created by Sascha Sallès on 21/04/2022.
//

import UIKit
import ARKit
import SceneKit
import Combine

class RobotARSportViewController: BaseRobotSceneViewController {

    // MARK: - Init

    init(with viewModel: RobotARSportViewModelDescriptor) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Private Properties

    private let viewModel: RobotARSportViewModelDescriptor
    private var subscriptions = Set<AnyCancellable>()

    private enum TrackingState {
        case detectingSurface
        case pointingAtSurface
        case readyToStart
        case started
    }

    private lazy var currentTrackingState: TrackingState = .detectingSurface
    private lazy var currentMessageForTrackingState: String = ""
    private lazy var currentTrackingStatus: String = ""
    private lazy var focusNode: SCNNode? = nil
    private lazy var robotNode: SCNNode? = nil

    // MARK: - UI
    private lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView(frame: view.frame)

        sceneView.antialiasingMode = .multisampling4X

        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.contentMode = .scaleAspectFit
        sceneView.rendersContinuously = true
        
        sceneView.delegate = self
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        return sceneView
    }()

    private lazy var coachingView: ARCoachingOverlayView = {
        let coachingView = ARCoachingOverlayView()
        coachingView.session = sceneView.session

        coachingView.delegate = self
        coachingView.translatesAutoresizingMaskIntoConstraints = false
        coachingView.activatesAutomatically = true
        coachingView.goal = .horizontalPlane

        return coachingView
    }()

    private lazy var startTapGestureRecognizer: UITapGestureRecognizer = {
        let recog = UITapGestureRecognizer(target: self, action: #selector(startTap))
        return recog
    }()


    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupScene()
        setupARSession()
        setupObservers()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.viewDidDisappear()
    }

    // MARK: - Private Methods

    private func setupObservers() {
        viewModel.performAnimationPublisher
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self] animation in
                switch animation {
                case .squat(let kind):
                    self?.performSquatAnimation(ofKind: kind)
                case .jumpingJack:
                    self?.performJumpingJackAnimation()
                }
            }
            .store(in: &subscriptions)

        viewModel.performResetARSessionPublisher
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] in
                self?.resetARSession()
            }
            .store(in: &subscriptions)

        viewModel.performToggleSceneStatsPublisher
            .sink { [weak self] shouldShowStats in
                self?.toggleDebugStats(shouldShowStats)
            }
            .store(in: &subscriptions)

        viewModel.performPauseARSessionPublisher
            .sink { [weak self]  in
                self?.pauseSession()
            }
            .store(in: &subscriptions)
    }

    private func setupUI() {
        view.addSubview(sceneView)
        sceneView.addSubview(coachingView)

        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.leftAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        NSLayoutConstraint.activate([
            coachingView.topAnchor.constraint(equalTo: sceneView.topAnchor),
            coachingView.leftAnchor.constraint(equalTo: sceneView.leftAnchor),
            coachingView.rightAnchor.constraint(equalTo: sceneView.rightAnchor),
            coachingView.bottomAnchor.constraint(equalTo: sceneView.bottomAnchor)
        ])

        sceneView.addGestureRecognizer(startTapGestureRecognizer)
    }


    private func setupScene() {
        let mainScene = SCNScene()
        sceneView.scene = mainScene

        if let robotScene = try? loadRobotScene() {
            robotNode = robotScene.rootNode
            robotNode?.isHidden = true
            sceneView.scene.rootNode.addChildNode(robotScene.rootNode)
        }

        if let focusScene = try? loadFocusScene() {
            focusNode = focusScene.rootNode
            focusNode?.isHidden = true
            sceneView.scene.rootNode.addChildNode(focusScene.rootNode)
        }
    }

    private func setupARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("AR World Tracking not supported on your device")
            return
        }

        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.providesAudioData = false
        config.isLightEstimationEnabled = true
        config.planeDetection = .horizontal

        config.environmentTexturing = .automatic
        sceneView.session.run(config)
    }

    private func pauseSession() {
        sceneView.session.pause()
    }

    private func loadRobotScene() throws -> SCNScene  {
        guard let url = viewModel.globalSceneURL else {
            throw SceneKitError.unableToLoad
        }
        let scene = try SCNScene(url: url)
        return scene
    }

    private func loadFocusScene() throws -> SCNScene {
        guard let url = viewModel.focusSceneURL else {
            throw SceneKitError.unableToLoad
        }
        let scene = try SCNScene(url: url)
        return scene
    }

    private func resetARSession() {
        currentTrackingState = .detectingSurface

        sceneView.scene.rootNode.childNodes.forEach { node in
            node.isHidden = true
        }

        guard let configuration = sceneView.session.configuration as? ARWorldTrackingConfiguration else { return }
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors, .stopTrackedRaycasts, .resetSceneReconstruction])
    }

    private func positionFocusNode() {
        guard currentTrackingState != .started else {
            focusNode?.isHidden = true
            return
        }

        let centerPoint = CGPoint(x: view.bounds.midX, y: view.bounds.midY)

        if let query = sceneView.raycastQuery(from: centerPoint,
                                              allowing: .estimatedPlane,
                                              alignment: .horizontal) {
            let results = sceneView.session.raycast(query)

            guard !results.isEmpty,
                  let match = results.first else {
                currentTrackingState = .pointingAtSurface
                focusNode?.isHidden = true
                return
            }

            let worldTransform = match.worldTransform

            focusNode?.position = SCNVector3(x: worldTransform.columns.3.x,
                                             y: worldTransform.columns.3.y,
                                             z: worldTransform.columns.3.z)
            currentTrackingState = .readyToStart
            focusNode?.isHidden = false
        }
    }

    private func toggleDebugStats(_ shouldShow: Bool) {
        sceneView.debugOptions = shouldShow ? [.showFeaturePoints, .showBoundingBoxes] : []
    }

    @objc private func startTap() {
        guard currentTrackingState == .readyToStart,
              let focusNode = self.focusNode,
              let robotNode = self.robotNode
        else { return }

        focusNode.isHidden = true
        robotNode.isHidden = false

        robotNode.position = focusNode.position
        currentTrackingState = .started
    }


    // MARK: - Animation Composition

    private func performJumpingJackAnimation() {
        let rootNode = self.sceneView.scene.rootNode

        guard let globalBody = rootNode.childNode(withName: "Global", recursively: true),
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
        let rootNode = self.sceneView.scene.rootNode
        
        guard let global = rootNode.childNode(withName: "Global", recursively: true),
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



// MARK: - ARSCNViewDelegate

extension RobotARSportViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.viewModel.isRobotNodeVisible.send(self.currentTrackingState == .started ? true : false)
            
            switch self.currentTrackingState {
            case .detectingSurface:
                self.currentMessageForTrackingState = "Searching a floor to make sports 💪"
            case .pointingAtSurface:
                self.currentMessageForTrackingState = "Looks good! Keep pointing at this surface"
            case .readyToStart:
                self.currentMessageForTrackingState = "Perfect! Tap to start ☝️"
            case .started:
                self.currentMessageForTrackingState = "Ready to make squats & jumping jacks 🤖"
            }
            self.viewModel.currentInfoText.send(
                self.currentTrackingStatus != "" ? "\(self.currentTrackingStatus)" : "\(self.currentMessageForTrackingState)"
            )
            self.positionFocusNode()
        }
    }
}

extension RobotARSportViewController {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            currentTrackingStatus = "Tracking: Not available"
        case .normal:
            currentTrackingStatus = ""
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                currentTrackingStatus = "Tracking: Excessive motion..."
            case .insufficientFeatures:
                currentTrackingStatus = "Tracking: Limited, Insufficient features"
            case .relocalizing:
                currentTrackingStatus = "Tracking: Relocalizing..."
            case .initializing:
                currentTrackingStatus = "Tracking: Initializing..."
            @unknown default:
                currentTrackingStatus = "Tracking: Unknown"
            }
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        viewModel.currentInfoText.send("The current AR Session has failed. Processing reset...")
        resetARSession()
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        viewModel.currentInfoText.send("The current AR Session was interrupted")
    }
}


// MARK: - ARCoachingOverlay Delegate

extension RobotARSportViewController: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        DispatchQueue.main.async { [weak self] in
            self?.resetARSession()
        }
    }

    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        DispatchQueue.main.async { [weak self] in
            self?.resetARSession()
        }
    }

    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {}
}
