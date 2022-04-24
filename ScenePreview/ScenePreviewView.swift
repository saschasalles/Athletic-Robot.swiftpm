//
//  ScenePreviewView.swift
//  
//
//  Created by Sascha Sallès on 20/04/2022.
//

import SwiftUI
import UIKit

struct ScenePreviewView: View {
    private let viewModel: ScenePreviewViewModelDescriptor

    init(with viewModel: ScenePreviewViewModelDescriptor){
        self.viewModel = viewModel
    }
}

extension ScenePreviewView: UIViewControllerRepresentable {

    typealias UIViewControllerType = SceneViewController

    func makeUIViewController(context: Context) -> SceneViewController {
        return SceneViewController(with: viewModel)
    }

    func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {

    }

}
