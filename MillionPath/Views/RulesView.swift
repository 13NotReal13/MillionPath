//
//  RulesView.swift
//  MillionPath
//
//  Created by Sergei Biryukov on 22.07.2025.
//

import SwiftUI

struct RulesView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    
    var body: some View {
        ZStack {
            Color.sheet
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Close") {
                        coordinator.dismissSheet()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Rules")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Spacer()
                        .frame(maxWidth: .infinity)
                }
                .padding()
                
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading) {
                        Text("""
                    Добро пожаловать в игру «Кто хочет стать миллионером»!

                    🔹 ЦЕЛЬ
                    Ответить правильно на 15 вопросов, чтобы выиграть $1,000,000.
                    
                    ✅ КАК ИГРАТЬ:
                    
                        1.    Выберите один из 4 вариантов ответа.
                    Только один из них правильный.
                        2.    На каждый вопрос дается 30 секунд.
                    Время ограничено, думайте быстро!
                        3.    С каждым уровнем приз растёт.
                    Чем дальше, тем выше награда.
                        4.    Некоторые суммы — несгораемые:
                        •    Вопрос 5 — $1,000
                        •    Вопрос 10 — $32,000
                    
                    🛟 ПОДСКАЗКИ:

                    Вы можете воспользоваться каждой подсказкой один раз за игру:

                    🔹 50:50 — убирает два неправильных варианта.
                    🔹 Помощь зала — зал голосует за правильный вариант 
                    🔹 Звонок другу — друг подсказывает
                    
                    💰 ЗАВЕРШИТЬ ИГРУ

                    Вы можете забрать деньги в любой момент до выбора ответа.

                    """
                        )
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .regular))
                        .lineSpacing(6)
                    }
                    .padding(.horizontal, 32)
                }
            }
        }
    }
}

#Preview {
    RulesView()
        .environmentObject(NavigationCoordinator.shared)
}
