//
//  AudioManager.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import AVFoundation

enum Sounds: String {
    case correct = "correctAnswer"
    case waiting = "waitingSound"
    case wrong = "wrongAnswer"
    case winner = "millionWin"
    case start = "startGame"
}

protocol AudioManagerProtocol {
    func playSound(_ sound: Sounds)
}

final class AudioManager: AudioManagerProtocol {
    static let shared = AudioManager()
    
    private var player: AVAudioPlayer?
    
    private init() {}
    
    func playSound(_ sound: Sounds) {
        stop()
        
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("Аудиофайл не найден")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("Ошибка воспроизведения: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        player?.stop()
    }
}
