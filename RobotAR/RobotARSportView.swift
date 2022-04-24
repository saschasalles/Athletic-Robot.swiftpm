//
//  RobotARSportView.swift
//  
//
//  Created by Sascha Sallès on 21/04/2022.
//

import SwiftUI
import UIKit
import ARKit

struct RobotARSportView: View {
    private let viewModel: RobotARSportViewModelDescriptor

    init(with viewModel: RobotARSportViewModelDescriptor) {
        self.viewModel = viewModel
    }
}

extension RobotARSportView: UIViewControllerRepresentable {
    typealias UIViewControllerType = RobotARSportViewController

    func makeUIViewController(context: Context) -> RobotARSportViewController {
        let viewController = RobotARSportViewController(with: viewModel)
        return viewController
    }

    func updateUIViewController(_ uiViewController: RobotARSportViewController, context: Context) { }
}
