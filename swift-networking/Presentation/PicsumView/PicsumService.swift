//
//  PicsumService.swift
//  swift-networking
//
//  Created by Vokal-Ican on 24/10/26.
//

import Foundation

final class PicsumService {
    
    private let client: APIClient
    
    init(client: APIClient = APIClient()) {
        self.client = client
    }
    
    func fetchPicsum(page: Int = 1, limit: Int = 30) async throws -> [PicsumModel] {
        try await client.request(
            url: "https://picsum.photos/v2/list",
            queryitems: [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "limit", value: "\(limit)")],
            as: [PicsumModel].self)
    }
}
