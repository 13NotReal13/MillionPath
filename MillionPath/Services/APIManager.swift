//
//  APIManager.swift
//  MillionPath
//
//  Created by Иван Семикин on 21/07/2025.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchAllQuestions() async throws -> [Question]
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private enum Constants {
        static let baseURL: String = "https://opentdb.com/api.php?"
        static let amountKey = "amount"
        static let amountValue = "30"
        static let typeKey = "type"
        static let typeValue = "multiple"
        static let difficultyKey = "difficulty"
        static let encodeKey = "encode"
        static let encodeValue = "url3986"
    }
    
    private init() {}
    
    var host: String {
        return Constants.baseURL
    }
    
    func fetchAllQuestions() async throws -> [Question] {
        var allQuestions: [Question] = []
        
        try await withThrowingTaskGroup(of: Response.self) { group in
            group.addTask {
                return try await self.fetch()
            }
            
            for try await response in group {
                let decodedQuestions = response.results.map { $0.decoded }
                allQuestions.append(contentsOf: decodedQuestions)
            }
        }
        
        return allQuestions
    }
    
    private func fetch<T: Decodable>(difficulty: Difficulty? = nil) async throws -> T {
        guard var components = URLComponents(string: host) else {
            throw NetworkError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: Constants.amountKey, value: Constants.amountValue),
            URLQueryItem(name: Constants.typeKey, value: Constants.typeValue),
            URLQueryItem(name: Constants.encodeKey, value: Constants.encodeValue)
        ]
        
        if let difficulty {
            components.queryItems?.append(URLQueryItem(name: Constants.difficultyKey, value: difficulty.rawValue))
        }
        
        guard let finalURL = components.url else {
            throw NetworkError.invalidURL
        }
                        
        let request = URLRequest(url: finalURL)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                throw NetworkError.invalidStatusCode(statusCode)
            }
            
            let decoder = JSONDecoder()
            
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
            
        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            } else if error is DecodingError {
                throw NetworkError.decodingError(error)
            } else {
                throw NetworkError.requestFailed(error)
            }
        }
    }
}
