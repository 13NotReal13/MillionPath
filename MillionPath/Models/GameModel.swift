//
//  GameModel.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation

struct Game {
    var currentQuestionIndex: Int = 0
    var usedHints: Set<Hint> = []
    var isFinished: Bool = false
    var isWinner: Bool = false
    var earnedAmount: Int = 0
    
    var timeRemaining: Int = 30
    
    var questions: [CurrentQuestion]
    let safeLevels: Set<Int> = [4, 9, 14]
    
    var currentQuestion: CurrentQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
}

enum Hint: String, CaseIterable, Hashable {
    case fiftyFifty
    case audience
    case friendsHelp
}
