//
//  BaseRobotSceneViewController.swift
//  
//
//  Created by Sascha Sallès on 24/04/2022.
//


import SceneKit

class BaseRobotSceneViewController: UIViewController {
    @discardableResult
    func squatShoulderRotation(on node: SCNNode,
                                       duration: TimeInterval,
                                       shouldRun: Bool = true,
                                       completion: (() -> Void)? = nil) -> SCNAction {

        let rotateXAction = SCNAction.rotateBy(x: -CGFloat.pi / 2, y: 0, z: 0, duration: duration)
        rotateXAction.timingMode = .easeOut

        if shouldRun {
            node.runAction(rotateXAction) {
                completion?()
            }
        }

        return rotateXAction
    }

    @discardableResult
    func squatTopBodyTranslate(ofKind kind: SquatKind,
                                       on node: SCNNode,
                                       duration: TimeInterval,
                                       shouldRun: Bool = true,
                                       completion: (() -> Void)? = nil) -> SCNAction {
        var translateAction: SCNAction

        switch kind {
        case .upper:
            translateAction = SCNAction.moveBy(x: 0, y: -15, z: -25, duration: duration)
        case .lower:
            translateAction = SCNAction.moveBy(x: 0, y: -30, z: -40, duration: duration)
        }

        if shouldRun {
            node.runAction(translateAction) {
                completion?()
            }
        }
        return translateAction
    }

    @discardableResult
    func squatKneeRotation(ofKind kind: SquatKind,
                                   on node: SCNNode,
                                   duration: TimeInterval,
                                   shouldRun: Bool = true,
                                   completion: (() -> Void)? = nil) -> SCNAction {
        var rotateXAction: SCNAction

        switch kind {
        case .upper:
            rotateXAction = SCNAction.rotateBy(x: -CGFloat.pi/3, y: 0, z: 0, duration: duration)
        case .lower:
            rotateXAction = SCNAction.rotateBy(x: -CGFloat.pi/2, y: 0, z: 0, duration: duration)
        }


        if shouldRun {
            node.runAction(rotateXAction) {
                completion?()
            }
        }
        return rotateXAction
    }



    // MARK: - Jumping Jack Animation

    func jumpingJackShoulderRotation(on node: SCNNode, duration: TimeInterval) {
        var rotateZAction = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi, duration: duration)
        var rotateYAction = SCNAction.rotateBy(x: 0, y: CGFloat.pi / 2, z: 0, duration: 0.13)

        if node.name == "RShoulderJoint" {
            rotateZAction = SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat.pi, duration: duration)
            rotateYAction = SCNAction.rotateBy(x: 0, y: -CGFloat.pi / 2, z: 0, duration: 0.13)
        }

        rotateZAction.timingMode = .easeIn
        rotateYAction.timingMode = .easeInEaseOut

        let actions = [rotateYAction, rotateZAction]
        let sequence = SCNAction.sequence(actions)
        sequence.timingMode = .easeOut
        let reversedSequence = sequence.reversed()
        reversedSequence.timingMode = .easeOut

        node.runAction(sequence) {
            node.runAction(reversedSequence)
        }
    }

    func jumpingJackLegsRotation(on node: SCNNode, duration: TimeInterval) {
        var rotateZAction = SCNAction.rotateBy(x: 0, y: 0, z: CGFloat.pi/5, duration: duration)

        if node.name == "RTopLeg" {
            rotateZAction = SCNAction.rotateBy(x: 0, y: 0, z: -CGFloat.pi/5, duration: duration)
        }

        rotateZAction.timingMode = .easeIn

        node.runAction(rotateZAction) {
            node.runAction(rotateZAction.reversed())
        }
    }

    func performLittleJump(on wholeBodyNode: SCNNode, duration: TimeInterval) {
        let jumpAction = SCNAction.moveBy(x: 0, y: 20, z: 0, duration: duration)
        jumpAction.timingMode = .easeIn

        wholeBodyNode.runAction(jumpAction) {
            wholeBodyNode.runAction(jumpAction.reversed())
        }
    }
}
