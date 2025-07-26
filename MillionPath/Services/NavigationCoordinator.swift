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

enum Sheet: Identifiable {
    case rules
    case audienceHelp(String)
    case friendHelp(String)
    
    var id: String {
        switch self {
        case .rules:
            return "rules"
        case .audienceHelp(let answer):
            return "audienceHelp_\(answer)"
        case .friendHelp(let answer):
            return "friendHelp_\(answer)"
        }
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
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    func present(sheet: Sheet) {
        self.sheet = sheet
    }
    
    func dismissSheet() {
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
            RulesView()
        case .audienceHelp(let answer):
            AudienceHelpView(answer: answer)
                .presentationDetents([.medium])
        case .friendHelp(let answer):
            FriendHelpView(answer: answer)
                .presentationDetents([.medium])
        }
    }
}
