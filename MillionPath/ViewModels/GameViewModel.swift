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
    case winner(score: Int)
}

@MainActor
class GameViewModel: ObservableObject {
    @Published var state: GameState = .loading
    @Published var currentQuestion: CurrentQuestion?
    
    private enum Constansts {
        static let costs: [Int] = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16_000, 32_000, 64_000, 125_000, 250_000, 500_000, 1_000_000]
        static let nonBurningCosts: [Int] = [1000, 32_000, 1_000_000]
    }
    
    private var currentQuestionIndex: Int = 0
    private var networkService: NetworkServiceProtocol
    private var questions: [Question] = []
    
    init(
        networkService: NetworkServiceProtocol = NetworkService.shared
    ) {
        self.networkService = networkService
        
        Task {
            await loadQuestions()
        }
    }
}

// MARK: - Бизнес логика

extension GameViewModel {
    
    func nextQuestion() {
        guard currentQuestionIndex + 1 <= Constansts.costs.count - 1 else {
            self.state = .gameOver(score: 3232) // логика очков
            return
        }
        
        currentQuestionIndex += 1
        getNextQuestion()
    }
    
    func gameOver() {
        self.state = .gameOver(score: 3232) // логика очков + не сгораемые
    }
    
    func newGame() {
        currentQuestionIndex = 0
        
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
    }
    
    /// Звонок другу
    func getFriendsHelp() {
        
    }
    
    /// Помощь зала
    func getExpertHelp() {
        
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
            self.questions = fetchedQuestions // логика мапы по сложности
            
            guard questions.count >= Constansts.costs.count else {
                self.state = .error(message: "Недостаточно вопросов для игры")
                return
            }
            
            self.getNextQuestion()
            self.state = .ready
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
