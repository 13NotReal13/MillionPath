//
//  AudienceVote.swift
//  MillionPath
//
//  Created by Sergey Zakurakin on 7/26/25.
//

import Foundation

// модель для голосования зала
struct AudienceVote: Identifiable {
    let id = UUID()
    let letter: String
    let answer: String
    let percentage: Int
}
