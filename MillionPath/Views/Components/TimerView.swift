//
//  TimerView.swift
//  MillionPath
//
//  Created by Иван Семикин on 25/07/2025.
//

import SwiftUI

struct TimerView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    
    var body: some View {
        HStack {
            Image(systemName: "stopwatch.fill")
                .resizable()
                .frame(width: 21, height: 21)
            Text("\(viewModel.game.timeRemaining)")
                .font(.title2)
                .fontWeight(.bold)
        }
        .foregroundStyle(viewModel.timerColor)
        .overlay {
            Capsule().fill(viewModel.timerColor.opacity(0.5))
                .frame(width: 91, height: 45)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(GameViewModel())
}
