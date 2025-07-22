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
