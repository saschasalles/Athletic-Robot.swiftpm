//
//  RobotPresentationViewModel.swift
//  
//
//  Created by Sascha Sallès on 20/04/2022.
//

import Combine
import Foundation
import SwiftUI

protocol RobotPresentationViewModelDescriptor {
    var currentText: AnyPublisher<String, Never> { get }
    var hasFinishedTextFlow: AnyPublisher<Bool, Never> { get }
    var scenePreviewViewModel: ScenePreviewViewModelDescriptor { get }
}


final class RobotPresentationViewModel: RobotPresentationViewModelDescriptor {

    init() {
        setupObservers()
    }
    // MARK: - Exposed Properties
    private(set) lazy var currentText: AnyPublisher<String, Never> = currentTextSubject.eraseToAnyPublisher()
    private(set) lazy var hasFinishedTextFlow: AnyPublisher<Bool, Never> = hasFinishedTextflowSubject.eraseToAnyPublisher()
    private(set) lazy var scenePreviewViewModel: ScenePreviewViewModelDescriptor = ScenePreviewViewModel(mode: .presenting)

    // MARK: - Private Properties

    private lazy var currentTextSubject = PassthroughSubject<String, Never>()
    private lazy var hasFinishedTextflowSubject = CurrentValueSubject<Bool, Never>(false)
    private lazy var accStrings = CurrentValueSubject<[String], Never>([])
    private lazy var accIndex = CurrentValueSubject<Int, Never>(0)
    private lazy var timerPublisher = Timer.publish(every: 1.2, on: .main, in: .common).autoconnect()
    
    private var subscriptions = Set<AnyCancellable>()


    // MARK: - Private Methods

    private func setupObservers() {
        timerPublisher
            .sink { [weak self] _ in
                guard let currentTextSubject = self?.currentTextSubject,
                      let accIndex = self?.accIndex,
                      let accStrings = self?.accStrings
                else { return }

                let robotSentences = Robot.shared.introSentences
                if accIndex.value < robotSentences.count {
                    var newArr = accStrings.value
                    newArr.append(robotSentences[accIndex.value])
                    accStrings.send(newArr)
                    currentTextSubject.send(accStrings.value.joined(separator: "\n"))
                    accIndex.send(accIndex.value + 1)
                }

                if accIndex.value == robotSentences.count {
                    self?.hasFinishedTextflowSubject.send(true)
                }
            }
            .store(in: &subscriptions)
    }
}
