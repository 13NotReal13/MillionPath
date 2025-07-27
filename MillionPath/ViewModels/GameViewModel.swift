//
//  GameViewModel.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation
import SwiftUI

enum GameState: Equatable {
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
    
    @Published var showAudienceHelp = false
    @Published var audienceAnswer: String = ""
    
    @Published var usedExtraLife = false
    @Published var extraLifeActive = false
 
    
    @Published var audienceVotes: [AudienceVote] = []
    
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

            for index in question.answers.indices where index != selectedIndex {
                question.answers[index].state = .normal
            }

            newGame.questions[questionIndex] = question
            game = newGame

            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let self = self else { return }
                self.nextQuestion()
                self.startTimer()
                self.userInteractionEnable = true
                self.soundService.playSound(.start)
            }

        } else {
            // Неверный ответ
            question.answers[selectedIndex].state = .incorrect
            question.answers[correctIndex].state = .correct
            soundService.playSound(.wrong)

            for index in question.answers.indices where index != selectedIndex && index != correctIndex {
                question.answers[index].state = .normal
            }

            newGame.questions[questionIndex] = question
            game = newGame

            if extraLifeActive {
                extraLifeActive = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let self = self else { return }
                    self.nextQuestion()
                    self.startTimer()
                    self.userInteractionEnable = true
                    self.soundService.playSound(.start)
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.gameOver()
                }
            }
        }
    }
    
    func newGame() {
        userInteractionEnable = true
        soundService.playSound(.start)
        game.currentQuestionIndex = 0
        game.timeRemaining = Constants.secondsForRound
        extraLifeActive = false
        usedExtraLife = false
        startTimer()
    }
    func pauseGame() {
        stopTimer()
        AudioManager.shared.pause()
    }
    
    func stopGame() {
        Task {
            await loadQuestions()
        }
        stopTimer()
        userInteractionEnable = false
        AudioManager.shared.stop()
        
        // Сбросить состояние подсказок и вопросов
        var newGame = game
        newGame.usedHints = []
        
        for i in 0..<newGame.questions.count {
            for j in 0..<newGame.questions[i].answers.count {
                newGame.questions[i].answers[j].state = .normal
            }
        }
        newGame.currentQuestionIndex = 0
        game = newGame
    }
    
    func continueGame() {
        AudioManager.shared.resume()
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
    
    /// Помощь зала
    func getExpertHelpVotes() -> [AudienceVote] {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return [] }
        let question = newGame.questions[newGame.currentQuestionIndex]
        let answers = question.answers
        let correctIndex = answers.firstIndex(where: { $0.isCorrect }) ?? 0

        let difficulty = question.difficulty
        let correctProb: Double = difficulty == .hard ? 0.5 : 0.7

        // Остаток делим на троих случайно
        let incorrectCount = answers.count - 1
        let totalLeft = 1.0 - correctProb

        // Генерируем случайные точки на отрезке [0, totalLeft], сортируем, получаем интервалы
        let points = (1..<incorrectCount).map { _ in Double.random(in: 0...totalLeft) }.sorted()
        var portions = [points.first ?? 0]
        for i in 1..<points.count {
            portions.append(points[i] - points[i-1])
        }
        portions.append(totalLeft - (points.last ?? 0))

        // Вставляем правильный ответ
        var result = [Double]()
        var pIndex = 0
        for i in 0..<answers.count {
            if i == correctIndex {
                result.append(correctProb)
            } else {
                result.append(portions[pIndex])
                pIndex += 1
            }
        }

        // В проценты, округляем, корректируем чтобы сумма была 100
        var intPercents = result.map { Int(round($0 * 100)) }
        let diff = 100 - intPercents.reduce(0, +)
        if let maxIndex = intPercents.enumerated().max(by: { $0.element < $1.element })?.offset {
            intPercents[maxIndex] += diff
        }

        let votes: [AudienceVote] = intPercents.enumerated().map { index, percent in
            let letter = ["A", "B", "C", "D"][index]
            return AudienceVote(letter: letter, answer: answers[index].answer, percentage: percent)
        }

        newGame.usedHints.insert(.audience)
        game = newGame

        return votes
    }
    
    /// Проверка: была ли подсказка использована
    func useFiftyFiftyHintIfNeeded() {
        guard !game.usedHints.contains(.fiftyFifty) else { return }
        get50_50Help()
    }
    
    func useAudienceHintIfNeeded() {
        guard !game.usedHints.contains(.audience) else { return }
        audienceVotes = getExpertHelpVotes()
        showAudienceHelp = true
    }
    
    func useSecondChanceIfNeeded() {
        guard !game.usedHints.contains(.extraLife) else { return }
        game.usedHints.insert(.extraLife)
        extraLifeActive = true
        usedExtraLife = true
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
    
    func gameOver(with score: Int? = nil) {
        var finalScore: Int
        
        if let score = score {
            finalScore = score
        } else {
            finalScore = getFinalScore()
        }
        
        self.state = .gameOver(score: finalScore)
        savingService.updateMaxScore(finalScore)
    }
    
    private func nextQuestion() {
        guard game.currentQuestionIndex + 1 <= Constants.costs.count - 1 else {
            gameOver()
            return
        }
        
        game.currentQuestionIndex += 1
        game.timeRemaining = Constants.secondsForRound
        extraLifeActive = false
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
        } catch let error as NetworkError {
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
        } catch {
            self.state = .error(message: error.localizedDescription)
        }
    }
}

// MARK: - Timer
extension GameViewModel {
    private func startTimer() {
        stopTimer()
        
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
