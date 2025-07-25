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
    @Published var state: GameState = .loading
    @Published var currentQuestion: CurrentQuestion?
    @Published var wasUsed50: Bool = false
    @Published var wasUsedFriends: Bool = false
    @Published var wasUsedExperts: Bool = false
    @Published var timeRemaining: Int = Constansts.secondsForRound
    @Published var userInteractionEnable: Bool = true
    
    private enum Constansts {
        static let costs: [Int] = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16_000, 32_000, 64_000, 125_000, 250_000, 500_000, 1_000_000]
        static let nonBurningCosts: [Int] = [0, 1000, 32_000, 1_000_000]
        static let friendsProbability: Double = 0.8
        static let expertsEasyProbability: Double = 0.7
        static let expertsHardProbability: Double = 0.5
        static let secondsForRound: Int = 30
    }
    
    private let networkService: NetworkServiceProtocol
    private let savingService: SaveResultServiceProtocol
    private let soundService: AudioManagerProtocol
    
    private var timer: Timer?
    private var currentQuestionIndex: Int = 0
    private var questions: [Question] = []
   
    init(
        networkService: NetworkServiceProtocol = NetworkService.shared,
        savingService: SaveResultServiceProtocol = SaveResultService.shared,
        soundService: AudioManagerProtocol = AudioManager.shared
    ) {
        self.networkService = networkService
        self.savingService = savingService
        self.soundService = soundService
        
        Task {
            await loadQuestions()
        }
    }
}

// MARK: - Бизнес логика

extension GameViewModel {
    // обработка ответа
    func selectAnswer(id: UUID) {
        guard var question = currentQuestion else { return }

        // Найдём правильный ответ
        guard let correctIndex = question.answers.firstIndex(where: { $0.state == .correct }) else { return }

        // Найдём индекс выбранного пользователем ответа
        guard let selectedIndex = question.answers.firstIndex(where: { $0.id == id }) else { return }

        // Если выбрали правильный
        if selectedIndex == correctIndex {
            question.answers[selectedIndex].state = .correct
        } else {
            // Если выбрали неправильный — отметим его и правильный
            question.answers[selectedIndex].state = .incorrect
            question.answers[correctIndex].state = .correct
        }

        // Остальные — в hidden
        for i in question.answers.indices {
            if i != selectedIndex && i != correctIndex {
                question.answers[i].state = .hidden
            }
        }

        currentQuestion = question
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
        currentQuestionIndex = 0
        wasUsed50 = false
        wasUsedFriends = false
        wasUsedExperts = false
//        getNextQuestion()
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
        let indexesToRemove = getIncorrectIndexes().shuffled()[..<2]
        
        guard indexesToRemove.count > 1 else {
            return
        }
        
        indexesToRemove.forEach { i in
            currentQuestion?.answers[i].state = .hidden
        }
        
        wasUsed50 = true
    }
    
    /// Звонок другу
    func getFriendsHelp() {
        if Double.random(in: 0...1) < Constansts.friendsProbability {
            if let rightAnswerIndex = currentQuestion?.answers.firstIndex(where: { $0.state == .correct }) {
                currentQuestion?.answers[rightAnswerIndex].state = .friendsAnswer
            }
        } else {
            if let wrongAnswerIndex = currentQuestion?.answers.firstIndex(where: { $0.state == .incorrect }) {
                currentQuestion?.answers[wrongAnswerIndex].state = .friendsAnswer
            }
        }
        
        wasUsedFriends = true
    }
    
    /// Помощь зала
    func getExpertHelp() -> [ExpertsHelpModel] {
        if let rightAnswerIndex = currentQuestion?.answers.firstIndex(where: { $0.state == .correct }) {
           let probability = currentQuestion?.isHard ?? false ? Constansts.expertsHardProbability : Constansts.expertsEasyProbability
            var expertsHelp: [ExpertsHelpModel] = []
            
            expertsHelp.append(
                ExpertsHelpModel(
                    answer: currentQuestion?.answers[rightAnswerIndex].answer ?? "",
                    probability: probability
                )
            )
            
            let remainingProbability = 1.0 - probability
            
            let incorrects = currentQuestion?.answers.filter { $0.state == .incorrect || $0.state == .friendsAnswer }
            
            for i in incorrects ?? [] {
                expertsHelp.append(
                    ExpertsHelpModel(
                        answer: i.answer,
                        probability: remainingProbability / Double(incorrects?.count ?? 1)
                    )
                )
            }
            
            wasUsedExperts = true
            return expertsHelp
        }
        
        return []
    }
    
    /// Забрать выйгрыш
    func takeMoneyNow() {
        gameOver(with: Constansts.costs[currentQuestionIndex])
    }
    
    func getFinalScore() -> Int {
        Constansts.nonBurningCosts.last(where: { last in
            last <= Constansts.costs[currentQuestionIndex]
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
        guard currentQuestionIndex + 1 <= Constansts.costs.count - 1 else {
            gameOver()
            return
        }
        
        currentQuestionIndex += 1
        getNextQuestion()
    }
    
    private func getNextQuestion() {
        self.currentQuestion = CurrentQuestion(
            model: questions[currentQuestionIndex],
            cost: Constansts.costs[currentQuestionIndex]
        )
    }
    
    private func getIncorrectIndexes() -> [Int] {
        return currentQuestion?.answers
            .enumerated()
            .filter { $0.element.state != .correct }
            .compactMap { $0.offset } ?? []
    }
    
    private func getRemainintIndexes() -> [Int] {
        return currentQuestion?.answers
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
        
        timeRemaining = Constansts.secondsForRound
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
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
        timeRemaining = Constansts.secondsForRound
    }
    
    private func handleTimeExpired() {
        gameOver()
    }
}
