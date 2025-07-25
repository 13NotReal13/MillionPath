//
//  SampleView.swift
//  MillionPath
//
//  Created by Andrei Panasenko on 25.07.2025.
//

import SwiftUI

struct SampleView: View {
    @ObservedObject var vm: GameViewModel = .init()
    @State var showAudienceHelp: Bool = false
    @State var expertsHelp: [ExpertsHelpModel] = []
    
    var body: some View {
        switch vm.state {
        case .loading:
            ProgressView()
        case .ready:
            VStack {
                Text(String(vm.timeRemaining))
                
                Text(vm.currentQuestion?.question ?? "")
                
                Spacer()
                
                ForEach(vm.currentQuestion?.answers ?? []) { a in
                    Button(a.state != .hidden ? a.answer : "") {
                        vm.checkAnswer(answer: a)
                    }
                    .foregroundColor(a.state == .friendsAnswer ? Color.orange : Color.green)
                    .disabled(a.state == .hidden)
                }
                
                Spacer()
                
                HStack {
                    Button("50/50") {
                        vm.get50_50Help()
                    }
                    .disabled(vm.wasUsed50)
                    
                    Button("experts") {
                        expertsHelp = vm.getExpertHelp()
                        showAudienceHelp.toggle()
                    }
                    .disabled(vm.wasUsedExperts)
                    
                    Button("friends") {
                        vm.getFriendsHelp()
                    }
                    .disabled(vm.wasUsedFriends)
                }
            }
            .allowsHitTesting(vm.userInteractionEnable)
            .sheet(isPresented: $showAudienceHelp) {
                ExpertsHelpBottomSheetView(expertsHelpData: expertsHelp)
            }
        case .error(let message):
            Text(message)
            Button("Попробовать еще раз") {
                Task {
                    await vm.reloadQuestions()
                }
            }
        case .gameOver(let score):
            Text("Ваш score: \(score)")
            Button("Заново") {
                vm.restartGame()
            }
        }
    }
}

struct BarView: View {
    let expertHelp: ExpertsHelpModel
    let maxProbability: Double
    
    var body: some View {
        VStack {
            Spacer()
            
            Rectangle()
                .fill(Color.blue)
                .frame(height: CGFloat(expertHelp.probability / maxProbability) * 150)
                .cornerRadius(4)
            
            Text(String(format: "%.0f%%", expertHelp.probability * 100))
                .font(.caption)
                .foregroundColor(.primary)
            
            Text(expertHelp.answer)
                .font(.headline)
                .padding(.top, 4)
                .foregroundColor(.primary)
        }
        .frame(width: 60)
    }
}

struct ExpertsHelpBottomSheetView: View {
    let expertsHelpData: [ExpertsHelpModel]
    @Environment(\.dismiss) var dismiss
    
    var maxProbability: Double {
        expertsHelpData.map { $0.probability }.max() ?? 1.0
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Помощь зала")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(expertsHelpData.sorted(by: { $0.answer < $1.answer })) { helpData in
                    BarView(expertHelp: helpData, maxProbability: maxProbability)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            
            Button("Закрыть") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding()
    }
}
