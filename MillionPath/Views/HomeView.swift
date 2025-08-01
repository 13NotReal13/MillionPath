//
//  HomeView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @AppStorage("maxScore") private var maxScore: Int = 0
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Spacer()
                Image("Logo")
                    .resizable()
                    .frame(width: 195.0, height: 195.0)
                
                VStack {
                    Text("All-time Best Score")
                        .foregroundStyle(.white)
                    
                    HStack {
                        Image("Coin")
                        
                        Text("\(maxScore)")
                            .foregroundStyle(.white)
                            .font(.system(size: 24, weight: .semibold))
                    }
                }
                
                Text("Who Wants \nto be a Millionair")
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Spacer()
                
                MainMenuButton(
                    title: "New Game",
                    isOrange: false,
                    action: { coordinator.push(.game) }
                )
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
        .ignoresSafeArea()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    coordinator.present(sheet: .rules)
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationCoordinator.shared)
}
