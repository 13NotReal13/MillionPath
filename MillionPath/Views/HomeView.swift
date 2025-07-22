//
//  HomeView.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    @State private var isSheetShowed: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.gradientBlue, .gradientBlack], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            Spacer()
            
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    Button(action: {
                        isSheetShowed.toggle()
                    }) {
                        Image(systemName: "questionmark.circle.fill")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.white)
                    }
                    .sheet(isPresented: $isSheetShowed) {
                        NavigationStack {
                            RulesView()
                                .toolbar {
                                    ToolbarItem(placement: .principal) {
                                        Text("Rules")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                    }
                                    ToolbarItem(placement: .topBarLeading) {
                                        Button("Close") {
                                            isSheetShowed = false
                                        }
                                    }
                                }
                        }
                    }
                }
                
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
    }
}

#Preview {
    HomeView()
}
