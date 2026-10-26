//
//  GithubModel.swift
//  swift-networking
//
//  Created by Vokal-Ican on 25/10/26.
//

struct GithubModel: Decodable {
    let id: Int
    let login: String
    
    enum CodingKeys: String, CodingKey { case id, login }
}
