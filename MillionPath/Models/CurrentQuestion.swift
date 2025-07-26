//
//  CurrentQuestion.swift
//  MillionPath
//
//  Created by Andrei Panasenko on 22.07.2025.
//

import Foundation

struct CurrentQuestion: Identifiable {
    struct Answer: Identifiable {
        enum QuestionState {
            case normal
            case selected
            case correct
            case incorrect
            case hidden
            case friendsAnswer
        }

        let answer: String
        let isCorrect: Bool
        var state: QuestionState
        let id: UUID = UUID()
    }
    
    let question: String
    let id: UUID = UUID()
    let cost: Int
    let isHard: Bool
    var answers: [Answer]
    let difficulty: Difficulty
    
    init(model: Question, cost: Int) {
        self.cost = cost
        self.question = model.question
        self.isHard = model.difficulty == .hard
        self.difficulty = model.difficulty
        
        var allAnswers = [Answer(answer: model.correctAnswer, isCorrect: true, state: .normal)]
        allAnswers += model.incorrectAnswers.map { Answer(answer: $0, isCorrect: false, state: .normal) }

        self.answers = allAnswers.shuffled()
    }
}
