//
//  PicsumModel.swift
//  swift-networking
//
//  Created by Vokal-Ican on 24/10/26.
//

struct PicsumModel: Decodable {
    let id: String
    let author: String
    let downloadURL: String
    
    enum CodingKeys: String, CodingKey {
        case id, author
        case downloadURL = "download_url"
    }
}
