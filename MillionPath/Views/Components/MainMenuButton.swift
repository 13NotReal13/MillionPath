//
//  MainMenuButton.swift
//  MillionPath
//
//  Created by Иван Семикин on 26/07/2025.
//

import SwiftUI

struct MainMenuButton: View {
    let title: String
    let isOrange: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 311, height: 62)
                .background(
                    isOrange
                        ? LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        : LinearGradient(
                            colors: [.blue, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
                .clipShape(CustomButtonShape())
                .overlay(
                    CustomButtonShape()
                        .stroke(Color.white, lineWidth: 4)
                )
        }
    }
}
