//
//  AudioManager.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    private var player: AVAudioPlayer?

    func playSound(named name: String, withExtension ext: String = "mp3") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
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
