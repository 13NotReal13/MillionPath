//
//  ResponseModel.swift
//  MillionPath
//
//  Created by Andrei Panasenko on 22.07.2025.
//

import Foundation

struct Response: Codable {
    let results: [Question]
    
    enum CodingKeys: String, CodingKey {
        case results
    }
}

struct Question: Codable, Identifiable {
    let id = UUID()
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]
    let difficulty: Difficulty
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case difficulty, category, question, type
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers"
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var intValue: Int {
        switch self {
        case .easy:
            return 1
        case .medium:
            return 2
        case .hard:
            return 3
        }
    }
}

