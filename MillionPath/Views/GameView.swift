//
//  GameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var vm: GameViewModel = .init()
    
    var body: some View {
        switch vm.state {
        case .loading:
            ProgressView()
        case .ready:
            VStack {
                Text(vm.currentQuestion?.question ?? "")
                
                ForEach(vm.currentQuestion?.answers ?? []) { a in
                    Button(a.state != .hidden ? a.answer : "") {
                        handleAnswer(a)
                    }
                    .disabled(a.state == .hidden) // нельзя нажать есть была подсказка
                }
                
                Button("50/50") {
                    vm.get50_50Help()
                }
            }
        case .error(let message):
            Text(message)
            Button("Попробовать еще раз") {
                Task {
                    await vm.reloadQuestions()
                }
            }
        case .gameOver(let score):
            Text("Ваш score: \(score)")
            Button("Заново") {
                vm.newGame()
            }
        case .winner(let score):
            Text("ура победил ты! Ваш score: \(score)")
            Button("Заново") {
                vm.newGame()
            }
        case .allQuestions(let score):
            Text("тут про текущий прогресс")
        }
    }
    
    private func handleAnswer(_ a: CurrentQuestion.Answer) {
        if a.state == .correct {
            vm.nextQuestion()
        } else {
            vm.gameOver()
        }
    }
}

#Preview {
    GameView()
}
