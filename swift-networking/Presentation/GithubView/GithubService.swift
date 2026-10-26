//
//  GithubService.swift
//  swift-networking
//
//  Created by Vokal-Ican on 25/10/26.
//

import Foundation

final class GithubService {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func fetchGithub() async throws -> [GithubModel] {
        guard let url = URL(string: "https://api.github.com/users") else { throw APIError.invalidURL }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError {
            throw APIError.transport(error)
        }
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        
        do {
            return try JSONDecoder().decode([GithubModel].self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
