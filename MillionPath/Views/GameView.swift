//
//  GameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

struct GameView: View {
    @StateObject private var viewModel = GameViewModel()
    
    private let timeRemaining = 30
    
    private let gradientfillColor = LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        ZStack {
            gradientfillColor
                .ignoresSafeArea()
            
            VStack {
                // Таймер
                HStack {
                    Image(systemName: "stopwatch.fill")
                        .resizable()
                        .frame(width: 21, height: 21)
                    Text("\(timeRemaining)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundStyle(.white)
                .overlay {
                    Capsule().fill(Color.white.opacity(0.5))
                        .frame(width: 91, height: 45)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                }
                
                // Вопрос
                Text(viewModel.currentQuestion?.question ?? "")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(height: 147)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                
                // Варианты ответа
                VStack(spacing: 16) {
                    if let question = viewModel.currentQuestion {
                        ForEach(Array(question.answers.enumerated()), id: \.element.id) { index, answer in
                            AnswerButtonView(index: index, answer: answer)
                                .onTapGesture {
                                    viewModel.selectAnswer(id: answer.id)
                                }
                        }
                    }
                }
                .padding(.bottom, 40)
                
                // Подсказки
                HStack(spacing: 24) {
                    HelpButton(icon: Image("50_50"), isUsed: viewModel.wasUsed50)
                    HelpButton(icon: Image("audience"), isUsed: viewModel.wasUsedExperts)
                    HelpButton(icon: Image("call"), isUsed: viewModel.wasUsedFriends)
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {}) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack(spacing: 4) {
                    Text("QUESTION #\(viewModel.currentQuestionIndex + 1)")
                        .foregroundColor(.white)
                        .font(.caption)
                    Text("$\(viewModel.currentQuestion?.cost ?? 0)")
                        .foregroundColor(.white)
                        .bold()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("barChart")
                    .foregroundColor(.white)
            }
        }
        .onAppear {
            viewModel.newGame()
        }
    }
}

#Preview {
    GameView()
}


struct AnswerButtonView: View {
    let index: Int
    let answer: CurrentQuestion.Answer
    
    var body: some View {
        let letter = ["A", "B", "C", "D"][index]
        
        Text("\(letter): \(answer.answer)")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 32)
            .background(gradient(for: answer.state))
            .clipShape(CustomButtonShape())
            .overlay(
                CustomButtonShape()
                    .stroke(Color.white, lineWidth: 4)
            )
            .padding(.horizontal)
        //            .opacity(answer.state == .hidden ? 1 : 1.0)
    }
    
    private func gradient(for state: CurrentQuestion.Answer.QuestionState) -> LinearGradient {
        switch state {
        case .hidden:
            return LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
        case .correct:
            return LinearGradient(colors: [.green, .green.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        case .incorrect:
            return LinearGradient(colors: [.red, .red.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        case .friendsAnswer:
            return LinearGradient(colors: [.yellow, .yellow.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        }
    }
}


// ToDo добавить логику нажатия
struct HelpButton: View {
    var icon: Image
    var isUsed: Bool
    
    var body: some View {
        icon
            .padding()
            .frame(width: 84, height: 64)
    }
}
