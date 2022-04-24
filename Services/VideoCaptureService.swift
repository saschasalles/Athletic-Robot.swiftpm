//
//  VideoCaptureService.swift
//  Sample Tests
//
//  Created by Sascha Sallès on 11/04/2022.
//

import Foundation
import Combine
import AVFoundation
import UIKit.UIDevice

enum VideoCaptureError: Error {
    case cantAddVideoInput
    case cantAddVideoOutput
    case cantAddIO
    case unaivalableCamera(Error?)
    case moreThan2SessionExists
    case failedToLoadConnection
}

//enum SessionSetupResult {
//    case success
//    case notAuthorized
//    case configurationFailed
//}

protocol VideoCaptureServiceDescriptor {
    var videoDataBufferPublisher: AnyPublisher<CMSampleBuffer, Never> { get }

    var session: AVCaptureSession { get }
    func startSession()
    func stopSession()
}

final class VideoCaptureService: NSObject, VideoCaptureServiceDescriptor {
    static let shared: VideoCaptureServiceDescriptor = VideoCaptureService()

    // MARK: - Exposed Properties
    private(set) lazy var videoDataBufferPublisher: AnyPublisher<CMSampleBuffer, Never> = videoBufferSubject.eraseToAnyPublisher()

    private(set) lazy var session = AVCaptureSession()

    // MARK: - Init

    private override init() {
        super.init()
        configureSession()
    }

    deinit {
        print(#function, self)
    }

    // MARK: - Exposed Methods

    func startSession() {
        session.startRunning()
    }

    func stopSession() {
        session.stopRunning()
    }

    // MARK: - Private Properties

    private let videoBufferSubject = PassthroughSubject<CMSampleBuffer, Never>()

    private lazy var videoOutput: AVCaptureVideoDataOutput? = nil

    private lazy var selectedCaptureDevice: AVCaptureDevice? = nil
    private lazy var selectedInput: AVCaptureDeviceInput? = nil

    private let queue = DispatchQueue(label: "com.athleticrobot.videocapture",
                                      qos: .userInitiated)

    private func configureSession() {
        stopSession()

        defer {
            session.commitConfiguration()
        }

        session.beginConfiguration()

        do {
            try configureInput()
            try configureOutput()
            try configureConnection()

            videoOutput?.setSampleBufferDelegate(self, queue: queue)

        } catch {
            print(error)
        }
    }

    private func configureInput() throws {
        // Ensuring that a camera is available
        // Default is ultra wide
        if let ultraWideCameraDevice = AVCaptureDevice.default(.builtInUltraWideCamera,
                                                               for: .video,
                                                               position: .front) {
            selectedCaptureDevice = ultraWideCameraDevice
        } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                                  for: .video,
                                                                  position: .front) {
            selectedCaptureDevice = frontCameraDevice
        }  else if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera,
                                                                  for: .video,
                                                                  position: .front) {
            selectedCaptureDevice = dualCameraDevice
        } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera,
                                                                     for: .video,
                                                                     position: .front) {
            selectedCaptureDevice = dualWideCameraDevice
        } else if let tripleCameraDevice = AVCaptureDevice.default(.builtInTripleCamera,
                                                                   for: .video,
                                                                   position: .front) {
            selectedCaptureDevice = tripleCameraDevice
        }

        guard let videoDevice = selectedCaptureDevice,
              videoDevice.get(with: WorkoutDetectionService.frameRate) else {
            print("⚠️ Default video device is unavailable.")
            return
        }

        session.inputs.forEach(session.removeInput)
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoDeviceInput) else { return }

        self.selectedInput = videoDeviceInput
    }

    private func configureOutput() throws {
        let videoDataOutput = AVCaptureVideoDataOutput()

        let pixelTypeKey = String(kCVPixelBufferPixelFormatTypeKey)
        videoDataOutput.videoSettings = [pixelTypeKey: kCVPixelFormatType_32BGRA]

        session.outputs.forEach(session.removeOutput)

        guard session.canAddOutput(videoDataOutput) else {
            throw VideoCaptureError.cantAddVideoOutput
        }

        self.videoOutput = videoDataOutput
    }

    private func configureConnection() throws {

        guard let videoInput = selectedInput,
              let videoOutput = videoOutput else { throw VideoCaptureError.cantAddIO }

        session.addInput(videoInput)
        session.addOutput(videoOutput)

        // This capture session must only have one connection.
        guard session.connections.count == 1 else {
            let count = session.connections.count
            print("The capture session has \(count) connections instead of 1.")
            fatalError()
        }

        guard let selectedCaptureDevice = selectedCaptureDevice else {
            throw VideoCaptureError.unaivalableCamera(nil)
        }

        guard let connection = session.connections.first else {
            throw VideoCaptureError.failedToLoadConnection
        }

        if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = .standard
        }

        if selectedCaptureDevice.supportsSessionPreset(.hd1920x1080) {
            session.sessionPreset = .hd1920x1080
        } else {
            session.sessionPreset = .high
        }

        videoOutput.alwaysDiscardsLateVideoFrames = true
    }


}


extension AVCaptureDevice {
    func get(with frameRate: Double) -> Bool {
        do {
            try lockForConfiguration()
        } catch {
            print("`AVCaptureDevice` wasn't unable to lock: \(error)")
            return false
        }

        defer { unlockForConfiguration() }

        let sortedRanges = activeFormat.videoSupportedFrameRateRanges.sorted {
            $0.maxFrameRate > $1.maxFrameRate
        }

        guard let range = sortedRanges.first, frameRate >= range.minFrameRate
        else { return false }

        let duration = CMTime(value: 1, timescale: CMTimeScale(frameRate))

        let inRange = frameRate <= range.maxFrameRate
        activeVideoMinFrameDuration = inRange ? duration : range.minFrameDuration
        activeVideoMaxFrameDuration = range.maxFrameDuration

        return true
    }
}

extension VideoCaptureService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        videoBufferSubject.send(sampleBuffer)
    }
}
