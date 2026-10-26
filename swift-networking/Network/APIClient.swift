//
//  APIClient.swift
//  swift-networking
//
//  Created by Vokal-Ican on 25/10/26.
//

import Foundation

final class APIClient {
    
    //bikin session
    private let session: URLSession
    
    //init session pake default .shared
    init(session: URLSession = NetworkSession.api) {
        self.session = session
    }
    
    //bikin func dengan generic T (semua data)
    //dan Decodable (langsung data dari jSON)
    //masukin parameter URL, method ini dan as type ini required
    //?? Opsional query params, headers
    
    func request<T: Decodable>(
        url: String,
        method: String = "GET",
        queryitems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        as type: T.Type
    ) async throws -> T {
        
        //susun URL pakai urlComponents
        var components = URLComponents(string: url)
        components?.queryItems = queryitems.isEmpty ? nil : queryitems
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        //susun requestnya pakai urlRequest
        var request = URLRequest(url: finalURL)
        request.httpMethod =  method
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        //set Data, dan response
        
        try await Task.sleep(for: .seconds(2))
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            throw APIError.transport(error)
        }
        
        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(http.statusCode) else {
            // DEBUG
            print("Status:", http.statusCode)
            print("Body:", String(data: data, encoding: .utf8) ?? "-")
            throw APIError.httpStatus(http.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
        
    }
}
