//
//  ProgressGameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 26/07/2025.
//

import SwiftUI

struct ProgressGameView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: GameViewModel
    
    let currentStep: Int
    let isGameOver: Bool
    let lastAnsweredIndex: Int?
    let isLastAnswerCorrect: Bool?
    
    private let costs: [Int] = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16_000, 32_000, 64_000, 125_000, 250_000, 500_000, 1_000_000]
    private let nonBurningIndices = [4, 9, 14]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Spacer()
                    
                    Button {
                        viewModel.continueGame()
                        coordinator.dismissFullScreenCover()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                ForEach(Array(costs.enumerated().reversed()), id: \.element) { index, cost in
                    let isCurrent = !isGameOver && index == currentStep - 1
                    let isLast = isGameOver && index == (lastAnsweredIndex ?? 0) - 1
                    let isNonBurning = nonBurningIndices.contains(index)
                    let isWin = isLast && (isLastAnswerCorrect ?? false)
                    let isLose = isLast && !(isLastAnswerCorrect ?? true)

                    StepProgressView(
                        number: index + 1,
                        cost: cost,
                        isCurrent: isCurrent,
                        isNonBurning: isNonBurning,
                        isWin: isWin,
                        isLose: isLose
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
    }
}

struct StepProgressView: View {
    let number: Int
    let cost: Int
    let isCurrent: Bool
    let isNonBurning: Bool
    let isWin: Bool
    let isLose: Bool

    var body: some View {
        HStack {
            Text("\(number):")
            Spacer()
            Text("$ \(cost.formatted(.number.grouping(.automatic)))")
        }
        .fontWeight(.bold)
        .padding(.horizontal, 32)
        .foregroundStyle(.white)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            isWin ? LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            : isLose ? LinearGradient(colors: [.red, .red.opacity(0.7)], startPoint: .top, endPoint: .bottom)
            : isCurrent ? LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .leading, endPoint: .trailing)
            : isNonBurning ? LinearGradient(colors: [Color.cyan, Color.blue], startPoint: .leading, endPoint: .trailing)
            : LinearGradient(colors: [Color.blue, Color.black], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(CustomButtonShape())
        .overlay(
            CustomButtonShape()
                .stroke(Color.white, lineWidth: 2)
        )
        .padding(.horizontal, 32)
    }
}

#Preview {
    ProgressGameView(
        currentStep: 10,
        isGameOver: true,
        lastAnsweredIndex: 3,
        isLastAnswerCorrect: true
    )
    .environmentObject(NavigationCoordinator.shared)
}
