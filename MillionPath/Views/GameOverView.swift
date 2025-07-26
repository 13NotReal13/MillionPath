//
//  GameOverView.swift
//  MillionPath
//
//  Created by Sergei Biryukov on 23.07.2025.
//

import SwiftUI

struct GameOverView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: GameViewModel
    
    @State var round: Int = 1
    @State var totalAmount: Double = 0
    var body: some View {
        ZStack {
            LinearGradient(colors: [.gradientBlue, .gradientBlack], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                Image("Logo")
                    .frame(width: 195.0, height: 195.0)
                
                Text("Game Over!")
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Text("Level \(viewModel.game.currentQuestionIndex + 1)/\(viewModel.game.questions.count)")
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .padding(.top, 16)
                
                HStack(spacing: 8) {
                    Image("Coin")
                    Text("$\(viewModel.getFinalScore())")
                        .font(.system(size: 24, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                }
                .padding(.top, 8)
                
                Spacer()
                
                VStack(spacing: 0) {
                    Button {
                        viewModel.stopGame()
                        coordinator.popToRoot()
                        coordinator.push(.game)
                    } label: {
                        Text("New Game")
                            .modifier(ButtonView(backgroundColors: LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]),startPoint: .leading, endPoint: .trailing)))
                    }
                    .padding(.bottom, 16)
                    
                    Button {
                        viewModel.stopGame()
                        coordinator.popToRoot()
                    } label: {
                        Text("Main Screen")
                            .modifier(ButtonView(backgroundColors: LinearGradient(gradient: Gradient(colors: [Color.gradientBlue, Color.gradientBlack]),startPoint: .top, endPoint: .bottom)))
                    }
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    GameOverView()
        .environmentObject(NavigationCoordinator.shared)
        .environmentObject(GameViewModel())
}
