//
//  AudioService.swift
//  
//
//  Created by Sascha Sallès on 16/04/2022.
//

import Foundation
import AVFAudio
import Combine

protocol AudioServiceDescriptor {
    func playAudio()
    func setupMusic(from fileURL: URL)
    func pausePlayer()
    func mute()
    func unmute()

    var isMuted: Bool? { get }
    var currentTime: TimeInterval? { get }
    var isPlayingValue: Bool { get }
    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
}

final class AudioService: NSObject, AudioServiceDescriptor {
    static let shared: AudioServiceDescriptor = AudioService()

    // MARK: - Exposed Properties

    var currentTime: TimeInterval? { player?.currentTime }


    private(set) lazy var isPlayingPublisher: AnyPublisher<Bool, Never> = isPlayingSubject.eraseToAnyPublisher()
    var isPlayingValue: Bool { isPlayingSubject.value }

    var isMuted: Bool? { player?.volume == 0 }

    func setupMusic(from fileURL: URL) {
        if nil != player {
            resetPlayer()
        }

        player = try? AVAudioPlayer(contentsOf: fileURL)
        player?.delegate = self
        player?.prepareToPlay()
    }

    func resetPlayer() {
        player?.stop()
        player = nil
    }

    func playAudio() {
        if let player = player {
            let isPlaying = player.play()
            isPlayingSubject.send(isPlaying)
        }
    }

    func pausePlayer() {
        if let player = player {
            player.pause()
            isPlayingSubject.send(false)
        }
    }

    func mute() {
        player?.setVolume(0.0, fadeDuration: 0.3)
    }

    func unmute() {
        player?.setVolume(1.0, fadeDuration: 0.3)
    }

    // MARK: - Private

    private var player: AVAudioPlayer?

    private lazy var isPlayingSubject = CurrentValueSubject<Bool, Never>(player?.isPlaying ?? false)

    private override init() {
        player?.prepareToPlay()
    }
}

extension AudioService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlayingSubject.send(false)
    }
}
