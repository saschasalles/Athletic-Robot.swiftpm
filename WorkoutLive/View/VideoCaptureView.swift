//
//  VideoCaptureView.swift
//  
//
//  Created by Sascha Sallès on 11/04/2022.
//

import UIKit
import AVFoundation

class VideoCaptureView: UIView {

    private(set) lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        guard let layer = layer as? AVCaptureVideoPreviewLayer else {
            fatalError("Failed to cast layer as AVCaptureVideoPreviewLayer")
        }
        return layer
    }()

    var session: AVCaptureSession? {
        get { videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }

    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
}

