//
//  MillionPathApp.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

@main
struct MillionPathApp: App {
    @StateObject private var coordinator = NavigationCoordinator.shared
    @StateObject private var gameViewModel = GameViewModel()
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView()
                .environmentObject(coordinator)
                .environmentObject(gameViewModel)
        }
    }
}
