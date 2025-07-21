//
//  NavigationCoordinator.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation
import SwiftUI

enum Page: String, Identifiable {
    case home
    case game
    
    var id: String {
        return self.rawValue
    }
}

enum Sheet: String, Identifiable {
    case rules
    
    var id: String {
        return self.rawValue
    }
}

final class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    
    static let shared = NavigationCoordinator()
    private init() {}
    
    func push(_ page: Page) {
        path.append(page)
    }
    
    func pop(_ page: Page) {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet: Sheet) {
        self.sheet = sheet
    }
    
    func dismiss() {
        sheet = nil
    }
    
    @ViewBuilder
    func build(page: Page) -> some View {
        switch page {
        case .home:
            HomeView()
        case .game:
            GameView()
        }
    }
    
    @ViewBuilder
    func build(sheet: Sheet) -> some View {
        switch sheet {
        case .rules:
            EmptyView()
        }
    }
}
