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
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.gradientBlue, .gradientBlack], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            Spacer()
            
            VStack(spacing: 16) {
                Spacer()
                Image("Logo")
                    .frame(width: 195.0, height: 195.0)
                
                Text("Who Wants \nto be a Millionair")
                    .font(.system(size: 32, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Spacer()
                
                Button(action: {
                    
                }) {
                    Text("New Game")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 311, height: 62)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(CustomButtonShape())
                        .overlay(
                            CustomButtonShape()
                                .stroke(Color.white, lineWidth: 4)
                        )
                    
                }
            }
            .padding(32)
        }
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
