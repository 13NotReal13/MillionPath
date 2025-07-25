//
//  GameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

struct GameView: View {
    // пока что с модели
    
    @State private var game = Game(questions: [
        CurrentQuestion(
            model: Question(
                category: "History",
                question: "What year was the year, when first deodorant was invented in our life?",
                correctAnswer: "First answer option",
                incorrectAnswers: ["Second answer option", "Third answer option", "Fourth answer option"],
                difficulty: .easy,
                type: "multiple"
            ),
            cost: 100
        )
    ])
    
    private let timeRemaining = 30
    
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
                    Text(game.currentQuestion?.question ?? "")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(height: 147)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    
                    // Варианты ответа
                    VStack(spacing: 12) {
                        ForEach(Array((game.currentQuestion?.answers ?? []).enumerated()), id: \.element.id) { index, answer in
                            AnswerButtonView(index: index, answer: answer)
                        }
                                            }
                    .padding(.bottom, 40)
                    
                    //Подсказки
                    HStack(spacing: 24) {
                        HelpButton(icon: Image(._50_50), isUsed: game.isHintUsed(.fiftyFifty))
                        HelpButton(icon: Image(.audience), isUsed: game.isHintUsed(.audience))
                        HelpButton(icon: Image(.call), isUsed: game.isHintUsed(.secondChance))
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
                        Text("QUESTION #\(game.currentIndex + 1)")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("$\(game.currentQuestion?.cost ?? 0)")
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
    var state: AnswerState = .correct
}

enum AnswerState {
    case normal
    case correct
    case incorrect
}

struct AnswerButtonView: View {
    let index: Int
    let answer: CurrentQuestion.Answer
    
    var body: some View {
        let letter = ["A", "B", "C", "D"][index]
        
        Text("\(letter): \(answer.answer)")
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
    
    private func backgroundColor(for state: CurrentQuestion.Answer.QuestionState) -> Color {
        switch state {
        case .hidden:
            return .clear
        case .correct:
            return .green
        case .incorrect:
            return .red
        case .friendsAnswer:
            return .yellow
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
