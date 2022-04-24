//
//  LivePreviewViewModel.swift
//  
//
//  Created by Sascha Sallès on 11/04/2022.
//

import Combine
import Foundation
import AVFoundation


protocol LivePreviewViewModelDescriptor {
    func getSession() -> AVCaptureSession
    func stopSession()
    func startSession()
}

final class LivePreviewViewModel: LivePreviewViewModelDescriptor {
    private let videoService: VideoCaptureServiceDescriptor

    init(with videoService: VideoCaptureServiceDescriptor) {
        self.videoService = videoService
    }

    func getSession() -> AVCaptureSession { videoService.session }

    func stopSession() { videoService.stopSession() }

    func startSession() { videoService.startSession() }
}
