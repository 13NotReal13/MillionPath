//
//  ProgressGameView.swift
//  MillionPath
//
//  Created by Иван Семикин on 26/07/2025.
//

import SwiftUI

struct ProgressGameView: View {
    private let costs: [Int] = [100, 200, 300, 500, 1000, 2000, 4000, 8000, 16_000, 32_000, 64_000, 125_000, 250_000, 500_000, 1_000_000]
    
    var body: some View {
        ZStack {
            VStack {
                ForEach(costs.reversed(), id: \.self) { cost in
                    Text("\(cost)")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BackgroundView())
    }
}

#Preview {
    ProgressGameView()
}
