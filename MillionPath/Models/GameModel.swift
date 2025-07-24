//
//  GameModel.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation

struct Game {
    // Индекс текущего вопроса (0...14)
    // Обновляется при правильном ответе
    private(set) var currentIndex: Int = 0
    // Набор использованных подсказок
    private(set) var usedHints: Set<Hint> = []
    // Флаг завершения игры (либо победа, либо проигрыш, либо "забрать деньги")
    private(set) var isFinished: Bool = false
    // Флаг победы (достигнут 15-й вопрос)
    private(set) var isWinner: Bool = false
    // Несгораемые уровни — по индексам (0-based: 5-й, 10-й, 15-й вопросы)
    private(set) var earnedAmount: Int = 0
    
    let questions: [CurrentQuestion]
    let safeLevels: Set<Int> = [4, 9, 14]
    
    var currentQuestion: CurrentQuestion? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }

    mutating func useHint(_ hint: Hint) {
        usedHints.insert(hint)
    }

    func isHintUsed(_ hint: Hint) -> Bool {
        usedHints.contains(hint)
    }

    // Обработка выбранного пользователем ответа (по UUID варианта)
    //
    // - Если ответ верный — повышаем индекс, увеличиваем сумму.
    // - Если достигнут конец — победа.
    // - Если ответ неверный — завершение, сумма = последняя несгораемая.
    mutating func answerSelected(index: UUID) {
        guard var question = currentQuestion else { return }

        let correctAnswer = question.answers.first(where: { $0.state == .correct })

        if correctAnswer?.id == index {
            earnedAmount = question.cost
            currentIndex += 1

            if currentIndex == questions.count {
                isFinished = true
                isWinner = true
            }
        } else {
            isFinished = true
            earnedAmount = safeLevels
                .filter { $0 <= currentIndex }
                .map { questions[$0].cost }
                .last ?? 0
        }
    }
}

enum Hint: String, CaseIterable, Hashable {
    case fiftyFifty
    case audience
    case secondChance
}
