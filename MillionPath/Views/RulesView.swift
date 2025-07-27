//
//  RulesView.swift
//  MillionPath
//
//  Created by Sergei Biryukov on 22.07.2025.
//

import SwiftUI

struct RulesView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        ZStack {
            Color.sheet
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Close") {
                        coordinator.dismissSheet()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Rules")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                .padding()
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        Text("""
                Welcome to “Who Wants to Be a Millionaire?”

                🔹 GOAL
                
                Answer 15 questions correctly to win $1,000,000.

                ✅ HOW TO PLAY:
                
                1. Choose one of the four answer options.
                Only one is correct.
                
                2. You have 30 seconds for each question.
                Time is limited, so think fast!
                
                3. The prize grows with each level.
                The further you go, the bigger the reward.
                
                4. Some amounts are guaranteed:
                    •    Question 5 — $1,000
                    •    Question 10 — $32,000

                🛟 HINTS:
                
                You can use each hint once per game:

                🔹 50:50 — removes two wrong options.
                🔹 Ask the Audience — the audience votes for the most likely answer.
                🔹 Second Chance — get one mistake for free.

                💰 END THE GAME

                You can take your winnings at any moment before selecting an answer.
                """
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .lineSpacing(6)
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
    }
}

#Preview {
    RulesView()
        .environmentObject(NavigationCoordinator.shared)
}
