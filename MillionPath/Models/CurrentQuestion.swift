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
            case correct
            case incorrect
            case hidden
            case friendsAnswer
        }
        
        let answer: String
        var state: QuestionState
        let id: UUID = UUID()
    }
    
    let question: String
    let id: UUID = UUID()
    let cost: Int
    let isHard: Bool
    var answers: [Answer]
    
    init(model: Question, cost: Int) {
        self.cost = cost
        self.question = model.question
        self.isHard = model.difficulty == .hard
        self.answers = [Answer(answer: model.correctAnswer, state: .correct)]
        + model.incorrectAnswers.map { Answer(answer: $0, state: .incorrect) }
    }
}
