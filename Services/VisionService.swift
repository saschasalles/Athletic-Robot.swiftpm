//
//  VisionService.swift
//  Sample Tests
//
//  Created by Sascha Sallès on 11/04/2022.
//

import Vision
import Foundation
import Combine
import CoreImage

enum VisionError: Error {
    case imageRequestFailed(Error)
    case sequenceRequestFailed
    case bodyRequestFailed(Error)
    case resultCastFailed
    case emptyResults
}

protocol VisionServiceDescriptor {
    func getMultiArray(from observation: VNHumanBodyPoseObservation) -> MLMultiArray?
    func detectBodyPosture(from buffer: CMSampleBuffer) throws -> [VNHumanBodyPoseObservation]?
}

final class VisionService: VisionServiceDescriptor {

    private let sequenceHandler = VNSequenceRequestHandler()

    deinit {
        print(#function, self)
    }

    func detectBodyPosture(from buffer: CMSampleBuffer) throws -> [VNHumanBodyPoseObservation]? {
        let bodyRequest = VNDetectHumanBodyPoseRequest()

        do {
            try sequenceHandler.perform([bodyRequest], on: buffer, orientation: .right)
        } catch {
            throw VisionError.sequenceRequestFailed
        }

        return bodyRequest.results
    }

    func getMultiArray(from observation: VNHumanBodyPoseObservation) -> MLMultiArray? {
           return try? observation.keypointsMultiArray()
    }
}
