//
//  GameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

struct GameView: View {
    // Заглушки
    private let questionNumber = 1
    private let prize = 100
    private let timeRemaining = 30
    private let questionText = "What year was the year, when first deodorant was invented in our life?"
    private let answers: [Answer] = [
        .init(id: UUID(), text: "First answer option"),
        .init(id: UUID(), text: "Second answer option"),
        .init(id: UUID(), text: "Third answer option"),
        .init(id: UUID(), text: "Fourth answer option")
    ]
    private let usedFiftyFifty = false
    private let usedAskAudience = false
    private let usedCallFriend = false
    
    // todoo
    let gradientfillColor = LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
        
    var body: some View {
        NavigationStack {
            ZStack {
                gradientfillColor
                    .ignoresSafeArea()
                
                VStack() {
                    
                    // Таймер
                    ZStack {
                        Capsule().fill(Color.white.opacity(0.2))
                            .frame(width: 91, height: 45)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                        HStack {
                            Image(.stopwatch)
                            
                            Text("\(timeRemaining)")
                                .foregroundStyle(.white)
                                .font(.title2)
                        }
                    }
                    
                    // Вопрос
                    Text(questionText)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(height: 147)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    
                    // Варианты ответа
                    VStack(spacing: 12) {
                        ForEach(Array(answers.enumerated()), id: \.element.id) { index, answer in
                            AnswerButtonView(index: index, answer: answer)
                        }
                    }
                    .padding(.bottom, 40)
                    
                    //Подсказки
                    HStack(spacing: 24) {
                        HelpButton(icon: Image(._50_50), isUsed: usedFiftyFifty)
                        HelpButton(icon: Image(.audience), isUsed: usedAskAudience)
                        HelpButton(icon: Image(.call), isUsed: usedCallFriend)
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 4) {
                        Text("QUESTION #\(questionNumber)")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("$\(prize)")
                            .foregroundColor(.white)
                            .bold()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(.barChart)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    GameView()
}



struct Answer: Identifiable {
    let id: UUID
    let text: String
    var state: AnswerState = .normal
}

enum AnswerState {
    case normal
    case correct
    case incorrect
}

struct AnswerButtonView: View {
    let index: Int
    let answer: Answer
    
    var body: some View {
        let letter = ["A", "B", "C", "D"][index]
        
        Text("\(letter): \(answer.text)")
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                CustomButtonShape()
                    .fill(backgroundColor(for: answer.state))
            )
            .overlay(
                CustomButtonShape()
                    .stroke(Color.white, lineWidth: 2)
            )
            .foregroundColor(.white)
    }
    
    private func backgroundColor(for state: AnswerState) -> Color {
        switch state {
        case .normal: return .clear
        case .correct: return .green
        case .incorrect: return .red
        }
    }
}

struct HelpButton: View {
    var icon: Image
    var isUsed: Bool
    
    var body: some View {
        icon
            .padding()
            .frame(width: 84, height: 64)
            .opacity(0.8)
    }
}
