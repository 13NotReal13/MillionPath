//
//  GameViewModel.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation
import SwiftUI

enum GameState {
    case loading
    case ready
    case error(message: String)
    case gameOver(score: Int)
}

struct ExpertsHelpModel: Identifiable {
    let id: UUID = UUID()
    let answer: String
    let probability: Double
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var game: Game
    @Published var state: GameState = .loading
    @Published var userInteractionEnable: Bool = true
    
    var timerColor: Color {
        switch self.game.timeRemaining {
        case ...10:
            return .red
        case 10..<20:
            return .orange
        default:
            return .white
        }
    }
    
    private enum Constants {
        static let costs: [Int] = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16_000, 32_000, 64_000, 125_000, 250_000, 500_000, 1_000_000]
        static let nonBurningCosts: [Int] = [0, 1000, 32_000, 1_000_000]
        static let friendsProbability: Double = 0.8
        static let expertsEasyProbability: Double = 0.7
        static let expertsHardProbability: Double = 0.5
        static let secondsForRound = 30
    }
    
    private let networkService: NetworkServiceProtocol
    private let savingService: SaveResultServiceProtocol
    private let soundService: AudioManagerProtocol
    
    private var timer: Timer?
   
    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        savingService: SaveResultServiceProtocol = SaveResultService.shared,
        soundService: AudioManagerProtocol = AudioManager.shared
    ) {
        self.networkService = networkService
        self.savingService = savingService
        self.soundService = soundService
        self.game = Game(questions: [])
        
        Task {
            await loadQuestions()
        }        
    }
}

// MARK: - Бизнес логика

extension GameViewModel {
    func selectAnswer(id: UUID) {
        guard userInteractionEnable else { return }
        var newGame = game
        guard let questionIndex = newGame.currentQuestionIndex as Int?,
              questionIndex < newGame.questions.count else { return }
        var question = newGame.questions[questionIndex]
        guard let selectedIndex = question.answers.firstIndex(where: { $0.id == id }) else { return }

        for index in question.answers.indices {
            question.answers[index].state = (index == selectedIndex) ? .selected : .normal
        }
        newGame.questions[questionIndex] = question
        game = newGame

        userInteractionEnable = false
        stopTimer()
        soundService.playSound(.waiting)

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.revealAnswer(selectedIndex: selectedIndex)
        }
    }

    func revealAnswer(selectedIndex: Int) {
        var newGame = game
        let questionIndex = newGame.currentQuestionIndex
        var question = newGame.questions[questionIndex]
        guard let correctIndex = question.answers.firstIndex(where: { $0.isCorrect }) else { return }

        if selectedIndex == correctIndex {
            question.answers[selectedIndex].state = .correct
            soundService.playSound(.correct)
        } else {
            question.answers[selectedIndex].state = .incorrect
            question.answers[correctIndex].state = .correct
            soundService.playSound(.wrong)
        }
        
        for index in question.answers.indices where index != selectedIndex && index != correctIndex {
            question.answers[index].state = .normal
        }
        newGame.questions[questionIndex] = question
        game = newGame

        // Переход к следующему вопросу или конец игры
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            if selectedIndex == correctIndex {
                self.nextQuestion()
                self.startTimer()
                self.userInteractionEnable = true
                self.soundService.playSound(.start)
            } else {
                self.gameOver()
            }
        }
    }
    
    func newGame() {
        game.currentQuestionIndex = 0
        soundService.playSound(.start)
        startTimer()
    }
    
    /// Подсказка 50/50
    func get50_50Help() {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return }
        var question = newGame.questions[newGame.currentQuestionIndex]

        // Находим неверные ответы
        let incorrectIndices = question.answers.enumerated()
            .filter { !$0.element.isCorrect && $0.element.state != .hidden }
            .map { $0.offset }
            .shuffled()
            .prefix(2)

        // Скрываем 2 неверных
        for index in incorrectIndices {
            question.answers[index].state = .hidden
        }

        newGame.questions[newGame.currentQuestionIndex] = question
        newGame.usedHints.insert(.fiftyFifty)
        game = newGame
    }
    
    /// Звонок другу
    func getFriendsHelp() -> String {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return "" }
        let question = newGame.questions[newGame.currentQuestionIndex]

        let isCorrect = Double.random(in: 0...1) < 0.8

        let answerText: String

        if isCorrect {
            answerText = question.answers.first(where: { $0.isCorrect })?.answer ?? ""
        } else {
            let incorrects = question.answers.filter { !$0.isCorrect && $0.state != .hidden }
            answerText = incorrects.randomElement()?.answer ?? ""
        }

        newGame.usedHints.insert(.friendsHelp)
        game = newGame
        return answerText
    }
    
    /// Помощь зала
    func getExpertHelp() -> String {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return "" }
        let question = newGame.questions[newGame.currentQuestionIndex]

        let probability = 0.7
        let isCorrect = Double.random(in: 0...1) < probability

        let answerText: String

        if isCorrect {
            answerText = question.answers.first(where: { $0.isCorrect })?.answer ?? ""
        } else {
            let incorrects = question.answers.filter { !$0.isCorrect && $0.state != .hidden }
            answerText = incorrects.randomElement()?.answer ?? ""
        }

        newGame.usedHints.insert(.audience)
        game = newGame
        return answerText
    }
    

    /// Проверка: была ли подсказка использована
        func useFiftyFiftyHintIfNeeded() {
            guard !game.usedHints.contains(.fiftyFifty) else { return }
            get50_50Help()
        }
        
        func useAudienceHintIfNeeded() -> String? {
            guard !game.usedHints.contains(.audience) else { return nil }
            return getExpertHelp()
        }

        func useFriendHintIfNeeded() -> String? {
            guard !game.usedHints.contains(.friendsHelp) else { return nil }
            return getFriendsHelp()
        }
    
    
    /// Забрать выйгрыш
    func takeMoneyNow() {
        gameOver(with: Constants.costs[game.currentQuestionIndex])
    }
    
    func getFinalScore() -> Int {
        Constants.nonBurningCosts.last(where: { last in
            last <= Constants.costs[game.currentQuestionIndex]
        }) ?? 0
    }
    
    private func nextQuestion() {
        guard game.currentQuestionIndex + 1 <= Constants.costs.count - 1 else {
            gameOver()
            return
        }
        
        game.currentQuestionIndex += 1
    }
    
    private func gameOver(with score: Int? = nil) {
        var finalScore: Int
        
        if let score = score {
            finalScore = score
        } else {
            finalScore = getFinalScore()
        }
        
        self.state = .gameOver(score: finalScore)
        savingService.updateMaxScore(finalScore)
    }
}

// MARK: - Сервисы
extension GameViewModel {
    private func loadQuestions() async {
        do {
            let fetchedQuestions = try await networkService.fetchAllQuestions()
            
            guard fetchedQuestions.count >= Constants.costs.count else {
                self.state = .error(message: "Недостаточно вопросов для игры")
                return
            }
             
            let sorted = fetchedQuestions.sorted { $0.difficulty.intValue < $1.difficulty.intValue }
            let currentQuestions = (0..<Constants.costs.count).map { index in
                CurrentQuestion(model: sorted[index], cost: Constants.costs[index])
            }
            self.game = Game(questions: currentQuestions)
            self.state = .ready
            //
//            self.startTimer()
//            self.soundService.playSound(.start)
            
//            newGame()

            
            
        }
        catch let error as NetworkError {
            var message: String
            switch error {
            case .invalidURL:
                message = "Неверный URL"
            case .requestFailed(let error):
                message = "Упал запрос \(error.localizedDescription)"
            case .invalidStatusCode(let int):
                message = "Статус код ответа \(int)"
            case .decodingError(let error):
                message = "Ошибка декодирования ответа \(error.localizedDescription)"
            }
            
            self.state = .error(message: message)
        }
        catch {
            self.state = .error(message: error.localizedDescription)
        }
    }
}

// MARK: - Timer
extension GameViewModel {
    private func startTimer() {
        stopTimer()
        
        game.timeRemaining = Constants.secondsForRound
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.game.timeRemaining > 0 {
                    self.game.timeRemaining -= 1
                } else {
                    self.stopTimer()
                    self.handleTimeExpired()
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleTimeExpired() {
        gameOver()
    }
}
