//
//  SaveResult.swift
//  MillionPath
//
//  Created by Andrei Panasenko on 25.07.2025.
//

import SwiftUI

protocol SaveResultServiceProtocol {
    
    func getMaxScore() -> Int
    func updateMaxScore(_ score: Int)
}

final class SaveResultService: SaveResultServiceProtocol {
    
    @AppStorage("maxScore") private var maxScore: Int = 0
    static let shared = SaveResultService()
    
    private init() {}
    
    func getMaxScore() -> Int {
        return maxScore
    }
    
    func updateMaxScore(_ score: Int) {
        if score > maxScore {
            maxScore = score
        }
    }
}
