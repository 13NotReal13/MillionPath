//
//  GameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: GameViewModel
    
    var body: some View {
        ZStack {
            VStack {
                TimerView()
                
                QuestionView()
                
                // Варианты ответа
                VStack(spacing: 16) {
                    if let question = viewModel.game.currentQuestion {
                        ForEach(Array(question.answers.enumerated()), id: \.element.id) { index, answer in
                            AnswerButtonView(index: index, answer: answer)
                                .onTapGesture {
                                    viewModel.selectAnswer(id: answer.id)
                                }
                                .disabled(!viewModel.userInteractionEnable)
                        }
                    }
                }
                .padding(.bottom, 40)
                
                // Подсказки
                HStack(spacing: 24) {
                    HelpButtonView(icon: Image("50_50"), isUsed: viewModel.game.usedHints.contains(.fiftyFifty))
                        .onTapGesture {
                            if !viewModel.game.usedHints.contains(.fiftyFifty) {
                                viewModel.get50_50Help()
                            }
                        }
                        .disabled(viewModel.game.usedHints.contains(.fiftyFifty))
                    
                    HelpButtonView(icon: Image("audience"), isUsed: viewModel.game.usedHints.contains(.audience))
                        .onTapGesture {
                            viewModel.useAudienceHintIfNeeded()
                            coordinator.present(sheet: .audienceHelp(viewModel.audienceAnswer))
                        }
                        .disabled(viewModel.game.usedHints.contains(.audience))

                    
                    HelpButtonView(icon: Image("call"), isUsed: viewModel.game.usedHints.contains(.friendsHelp))
                        .onTapGesture {
                                viewModel.useFriendHintIfNeeded()
                            }
                            .disabled(viewModel.game.usedHints.contains(.friendsHelp))
                }
            }
            .padding()
        }
        .environmentObject(viewModel)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
        .navigationBarBackButtonHidden()
        
        .onAppear{
            viewModel.newGame()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.stopGame()
                    coordinator.pop()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                }
            }
            
            ToolbarItem(placement: .principal) {
                VStack(spacing: 4) {
                    Text("QUESTION #")
                        .foregroundColor(.white)
                        .font(.caption)
                    Text("$\(viewModel.game.currentQuestion?.cost ?? 0)")
                        .foregroundColor(.white)
                        .bold()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Image("barChart")
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $viewModel.showFriendHelp) {
            FriendHelpView(answer: viewModel.friendAnswer)
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    NavigationStack {
        GameView()
            .environmentObject(NavigationCoordinator.shared)
            .environmentObject(GameViewModel())
    }
}


struct AnswerButtonView: View {
    let index: Int
    let answer: CurrentQuestion.Answer
    
    var body: some View {
        let letter = ["A", "B", "C", "D"][index]
        
        HStack(alignment: .center, spacing: 0) {
            Text("\(letter): ")
                .foregroundColor(.orange)
            
            Text(answer.answer)
                .foregroundColor(.white)
            
            Spacer()
        }
        .font(.system(size: 20, weight: .semibold))
        .padding(.vertical)
        .padding(.leading, 32)
        .frame(maxWidth: .infinity)
        .background(gradient(for: answer.state))
        .clipShape(CustomButtonShape())
        .overlay(
            CustomButtonShape()
                .stroke(Color.white, lineWidth: 4)
        )
        .padding(.horizontal)
    }
    
    private func gradient(for state: CurrentQuestion.Answer.QuestionState) -> LinearGradient {
        switch state {
        case .normal:
            return LinearGradient(colors: [.blue, .black], startPoint: .top, endPoint: .bottom)
        case .selected:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .top, endPoint: .bottom)
        case .correct:
            return LinearGradient(colors: [.green, .green.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        case .incorrect:
            return LinearGradient(colors: [.red, .red.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        case .hidden:
            return LinearGradient(colors: [.gray.opacity(0.1), .gray.opacity(0.1)], startPoint: .top, endPoint: .bottom)
        case .friendsAnswer:
            return LinearGradient(colors: [.yellow, .yellow.opacity(0.2)], startPoint: .top, endPoint: .bottom)
        }
    }
}

struct HelpButtonView: View {
    var icon: Image
    var isUsed: Bool
    
    var body: some View {
        icon
            .padding()
            .frame(width: 84, height: 64)
            .opacity(isUsed ? 0.5 : 1.0)
    }
}


struct AudienceHelpView: View {
    let answer: String

    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Помощь зала")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                Text("Зал считает, что правильный ответ:")
                    .foregroundStyle(.white)
                    .font(.body)
                
                Text(answer)
                    .font(.title)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            }
            .padding()
        }
    }
}


struct FriendHelpView: View {
    let answer: String

    var body: some View {
        ZStack {
            BackgroundView()
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Звонок другу")
                    .foregroundStyle(.white)
                    .font(.title)
                    .bold()
                    .padding(.top)
                
                Text("Друг считает, что правильный ответ:")
                    .foregroundStyle(.white)
                    .font(.body)
                
                Text(answer)
                    .font(.title)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Spacer()
            }
            .padding()
        }
    }
}
