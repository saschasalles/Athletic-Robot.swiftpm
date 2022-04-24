//
//  LivePreview.swift
//  
//
//  Created by Sascha Sallès on 10/04/2022.
//

import SwiftUI
import UIKit
import AVFoundation

struct LivePreviewView: View {
    private var viewModel: LivePreviewViewModelDescriptor = LivePreviewViewModel(with: VideoCaptureService.shared)
}

extension LivePreviewView: UIViewControllerRepresentable {
    typealias UIViewControllerType = LivePreviewViewController

    func makeUIViewController(context: Context) -> LivePreviewViewController {
        let viewController = LivePreviewViewController(with: viewModel)
        return viewController
    }

    func updateUIViewController(_ uiViewController: LivePreviewViewController, context: Context) {
        // Not needed
    }
}
