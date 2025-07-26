//
//  MenuGameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 26/07/2025.
//

import SwiftUI

struct MenuGameView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var viewModel: GameViewModel
    
    var body: some View {
        VStack {
            MainMenuButton(
                title: "Continue Game",
                isOrange: true,
                action: {
                    viewModel.continueGame()
                    coordinator.dismissFullScreenCover()
                }
            )
            
            MainMenuButton(
                title: "Go Home",
                isOrange: false,
                action: {
                    viewModel.stopGame()
                    coordinator.dismissFullScreenCover()
                    coordinator.pop()
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
    }
}

#Preview {
    MenuGameView()
        .environmentObject(NavigationCoordinator.shared)
        .environmentObject(GameViewModel())
}
