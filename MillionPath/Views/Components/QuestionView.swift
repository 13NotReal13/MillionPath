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
        Text(viewModel.game.currentQuestion?.question ?? "")
            .font(.title3)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .frame(height: 147)
            .padding(.horizontal)
            .padding(.bottom, 32)
    }
}

#Preview {
    QuestionView()
        .environmentObject(GameViewModel())
}
