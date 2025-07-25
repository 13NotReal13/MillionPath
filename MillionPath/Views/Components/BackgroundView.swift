//
//  BackgroundView.swift
//  MillionPath
//
//  Created by Иван Семикин on 25/07/2025.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Rectangle()
              .foregroundColor(.clear)
              .frame(width: 321, height: 321)
              .background(Color(red: 0.15, green: 0.69, blue: 1))
              .cornerRadius(321)
              .blur(radius: 87)
              .opacity(0.8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
          LinearGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.22, green: 0.3, blue: 0.58), location: 0.00),
              Gradient.Stop(color: Color(red: 0.06, green: 0.05, blue: 0.09), location: 1.00),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1)
          )
        )
    }
}

#Preview {
    BackgroundView()
}
