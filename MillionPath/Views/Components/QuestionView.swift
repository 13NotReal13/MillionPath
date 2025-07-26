//
//  QuestionView.swift
//  MillionPath
//
//  Created by Иван Семикин on 25/07/2025.
//

import SwiftUI

struct QuestionView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            if let question = viewModel.game.currentQuestion {
                Text(viewModel.game.currentQuestion?.question ?? "")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .frame(height: 147)
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                    .id(question.id)
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        )
                    )
                    .animation(.easeInOut(duration: 0.5), value: question.id)
            }
        }
    }
}

#Preview {
    QuestionView()
        .environmentObject(GameViewModel())
}
