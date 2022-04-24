//
//  LivePreviewViewController.swift
//
//
//  Created by Sascha Sallès on 10/04/2022.
//

import UIKit
import AVFoundation
import Vision

class LivePreviewViewController: UIViewController {
    private var viewModel: LivePreviewViewModelDescriptor

    private(set) lazy var previewView: VideoCaptureView = {
        let preview = VideoCaptureView()
        view.addSubview(preview)
        return preview
    }()

    private lazy var videoPreviewLayer: AVCaptureVideoPreviewLayer = {
        let layer = previewView.videoPreviewLayer
        return layer
    }()

    // MARK: - Init

    init(with viewModel: LivePreviewViewModelDescriptor) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        previewView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            previewView.topAnchor.constraint(equalTo: view.topAnchor),
            previewView.rightAnchor.constraint(equalTo: view.rightAnchor),
            previewView.leftAnchor.constraint(equalTo: view.leftAnchor),
            previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill

        previewView.session = viewModel.getSession()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }


    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.stopSession()
    }

    override var shouldAutorotate: Bool { false }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

}


