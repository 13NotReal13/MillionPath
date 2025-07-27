//
//  Elements.swift
//  MillionPath
//
//  Created by Sergei Biryukov on 22.07.2025.
//

import SwiftUI

struct CustomButtonShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let cut: CGFloat = 20
        
        path.move(to: CGPoint(x: rect.minX + cut, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX - cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + cut, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        
        return path
    }
}

struct ButtonView: ViewModifier {
    var backgroundColors: LinearGradient
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 311, height: 62)
            .background(
                backgroundColors
            )
            .clipShape(CustomButtonShape())
            .overlay(
                CustomButtonShape()
                    .stroke(Color.white, lineWidth: 4)
            )
    }
}
