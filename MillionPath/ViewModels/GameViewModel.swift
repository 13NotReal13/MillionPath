//
//  GameViewModel.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation

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
    
    private enum Constansts {
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
//    private var currentQuestionIndex: Int = 0
    private var questions: [Question] = []
   
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
    // обработка ответа
    func selectAnswer(id: UUID) {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return }
        var question = newGame.questions[newGame.currentQuestionIndex]

        guard let correctIndex = question.answers.firstIndex(where: { $0.state == .correct }) else { return }
        guard let selectedIndex = question.answers.firstIndex(where: { $0.id == id }) else { return }

        if selectedIndex == correctIndex {
            question.answers[selectedIndex].state = .correct
        } else {
            question.answers[selectedIndex].state = .incorrect
            question.answers[correctIndex].state = .correct
        }
        for i in question.answers.indices {
            if i != selectedIndex && i != correctIndex {
                question.answers[i].state = .hidden
            }
        }
        newGame.questions[newGame.currentQuestionIndex] = question
        game = newGame
    }
    
    func checkAnswer(answer: CurrentQuestion.Answer) {
        soundService.playSound(.waiting)
        userInteractionEnable = false
        stopTimer()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            self?.checkAnswer(answer)
            self?.userInteractionEnable = true
        }
    }
    
    func newGame() {
        game.currentQuestionIndex = 0
        startTimer()
    }
    
    func restartGame() {
        newGame()
        Task {
            await reloadQuestions()
        }
    }
    
    /// Подсказка 50/50
    func get50_50Help() {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return }
        var question = newGame.questions[newGame.currentQuestionIndex]

        let indexesToRemove = question.answers
            .enumerated()
            .filter { $0.element.state != .correct }
            .map { $0.offset }
            .shuffled()
            .prefix(2)

        for i in indexesToRemove {
            question.answers[i].state = .hidden
        }
        newGame.questions[newGame.currentQuestionIndex] = question
        newGame.usedHints.insert(.fiftyFifty)
        game = newGame
    }
    
    /// Звонок другу
    func getFriendsHelp() {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return }
        var question = newGame.questions[newGame.currentQuestionIndex]

        if Double.random(in: 0...1) < Constansts.friendsProbability {
            if let rightAnswerIndex = question.answers.firstIndex(where: { $0.state == .correct }) {
                question.answers[rightAnswerIndex].state = .friendsAnswer
            }
        } else {
            if let wrongAnswerIndex = question.answers.firstIndex(where: { $0.state == .incorrect }) {
                question.answers[wrongAnswerIndex].state = .friendsAnswer
            }
        }

        newGame.questions[newGame.currentQuestionIndex] = question
        newGame.usedHints.insert(.friendsHelp)
        game = newGame
    }
    
    /// Помощь зала
    func getExpertHelp() -> [ExpertsHelpModel] {
        var newGame = game
        guard newGame.currentQuestionIndex < newGame.questions.count else { return [] }
        let question = newGame.questions[newGame.currentQuestionIndex]

        guard let rightAnswerIndex = question.answers.firstIndex(where: { $0.state == .correct }) else { return [] }

        let probability = question.isHard ? Constansts.expertsHardProbability : Constansts.expertsEasyProbability
        var expertsHelp: [ExpertsHelpModel] = []

        expertsHelp.append(
            ExpertsHelpModel(
                answer: question.answers[rightAnswerIndex].answer,
                probability: probability
            )
        )

        let remainingProbability = 1.0 - probability

        let incorrects = question.answers.filter { $0.state == .incorrect || $0.state == .friendsAnswer }

        for i in incorrects {
            expertsHelp.append(
                ExpertsHelpModel(
                    answer: i.answer,
                    probability: remainingProbability / Double(incorrects.count == 0 ? 1 : incorrects.count)
                )
            )
        }

        newGame.usedHints.insert(.audience)
        game = newGame
        return expertsHelp
    }
    
    /// Забрать выйгрыш
    func takeMoneyNow() {
        gameOver(with: Constansts.costs[game.currentQuestionIndex])
    }
    
    func getFinalScore() -> Int {
        Constansts.nonBurningCosts.last(where: { last in
            last <= Constansts.costs[game.currentQuestionIndex]
        }) ?? 0
    }
    
    private func checkAnswer(_ answer: CurrentQuestion.Answer) {
        if answer.state == .correct {
            nextQuestion()
            soundService.playSound(.correct)
            startTimer()
        } else {
            gameOver()
        }
    }
    
    private func nextQuestion() {
        guard game.currentQuestionIndex + 1 <= Constansts.costs.count - 1 else {
            gameOver()
            return
        }
        
        game.currentQuestionIndex += 1
    }
    
    private func getIncorrectIndexes() -> [Int] {
        return game.currentQuestion?.answers
            .enumerated()
            .filter { $0.element.state != .correct }
            .compactMap { $0.offset } ?? []
    }
    
    private func getRemainintIndexes() -> [Int] {
        return game.currentQuestion?.answers
            .enumerated()
            .filter { $0.element.state != .correct || $0.element.state != .hidden }
            .compactMap { $0.offset } ?? []
    }
    
    private func gameOver(with score: Int? = nil) {
        var finalScore: Int
        
        if let score = score {
            finalScore = score
        } else {
            finalScore = getFinalScore()
        }
        
        if finalScore == Constansts.costs.last {
            soundService.playSound(.winner)
        } else {
            soundService.playSound(.wrong)
        }
        
        self.state = .gameOver(score: finalScore)
        savingService.updateMaxScore(finalScore)
    }
}

// MARK: - Сервисы

extension GameViewModel {
    
    /// Для перезагрузки вопросов если что то пошло не так
    func reloadQuestions() async {
        state = .loading
        await loadQuestions()
    }
    
    private func loadQuestions() async {
        do {
            let fetchedQuestions = try await networkService.fetchAllQuestions()
            
            guard fetchedQuestions.count >= Constansts.costs.count else {
                self.state = .error(message: "Недостаточно вопросов для игры")
                return
            }
             
            self.questions = fetchedQuestions.sorted { $0.difficulty.intValue < $1.difficulty.intValue}
            self.state = .ready
            self.newGame()
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
    
    func startTimer() {
        stopTimer()
        
        game.timeRemaining = Constansts.secondsForRound
        
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
    
    private func resetTimer() {
        stopTimer()
        game.timeRemaining = Constansts.secondsForRound
    }
    
    private func handleTimeExpired() {
        gameOver()
    }
}
