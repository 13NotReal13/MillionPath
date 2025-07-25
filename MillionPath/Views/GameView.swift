//
//  GameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

struct GameView: View {
    
    // пока что с модели
    @State private var answers: [CurrentQuestion.Answer] = []
    
    @State private var vm = Game(questions: [
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
    
    private let gradientfillColor = LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
    
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
                    Text(vm.currentQuestion?.question ?? "")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(height: 147)
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    
                    // Варианты ответа
                    VStack(spacing: 16) {
                        //                        ForEach(Array((vm.currentQuestion?.answers ?? []).enumerated()), id: \.element.id) { index, answer in
                        ForEach(Array(answers.enumerated()), id: \.element.id) { index, answer in
                            AnswerButtonView(index: index, answer: answer)
                                .onTapGesture {
                                    answers = answers.enumerated().map { i, answer in
                                        var updated = answer
                                        updated.state = (i == index) ? .correct : .incorrect
                                        return updated
                                    }
                                }
                        }
                    }
                    .padding(.bottom, 40)
                    
                    //Подсказки
                    HStack(spacing: 24) {
                        HelpButton(icon: Image(._50_50), isUsed: vm.isHintUsed(.fiftyFifty))
                        HelpButton(icon: Image(.audience), isUsed: vm.isHintUsed(.audience))
                        HelpButton(icon: Image(.call), isUsed: vm.isHintUsed(.secondChance))
                    }
                }
                .padding()
                .onAppear {
                    if let question = vm.currentQuestion {
                        answers = question.answers
                    }
                }
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
                        Text("QUESTION #\(vm.currentIndex + 1)")
                            .foregroundColor(.white)
                            .font(.caption)
                        Text("$\(vm.currentQuestion?.cost ?? 0)")
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

//struct Answer: Identifiable {
//    let id: UUID
//    let text: String
//    var state: AnswerState = .correct
//}

//enum AnswerState {
//    case normal
//    case correct
//    case incorrect
//}

struct AnswerButtonView: View {
    let index: Int
    let answer: CurrentQuestion.Answer
    
    var body: some View {
        let letter = ["A", "B", "C", "D"][index]
        
        Text("\(letter): \(answer.answer)")
            .padding()
            .frame(maxWidth: .infinity)
        // заменить потом для состояния на answer.state
            .modifier(ButtonView(backgroundColors: gradient(for: answer.state)))
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

//    private func backgroundColor(for state: CurrentQuestion.Answer.QuestionState) -> Color {
//        switch state {
//        case .hidden:
//            return .clear
//        case .correct:
//            return .green
//        case .incorrect:
//            return .red
//        case .friendsAnswer:
//            return .yellow
//        }
//}

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
