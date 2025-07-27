//
//  CoordinatorView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

struct CoordinatorView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.build(page: .home)
                .navigationDestination(for: Page.self) { page in
                    coordinator.build(page: page)
                }
                .sheet(item: $coordinator.sheet) { sheet in
                    coordinator.build(sheet: sheet)
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { fullScreenCover in
                    coordinator.build(fullScreenCover: fullScreenCover)
                }
        }
    }
}

#Preview {
    CoordinatorView()
        .environmentObject(NavigationCoordinator.shared)
}
