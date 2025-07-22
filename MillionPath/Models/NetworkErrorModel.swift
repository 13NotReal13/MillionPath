//
//  NetworkErrorModel.swift
//  MillionPath
//
//  Created by Andrei Panasenko on 22.07.2025.
//

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidStatusCode(Int)
    case decodingError(Error)
}
