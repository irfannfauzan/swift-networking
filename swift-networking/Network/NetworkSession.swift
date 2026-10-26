//
//  NetworkSession.swift
//  swift-networking
//
//  Created by Vokal-Ican on 24/10/26.
//

import Foundation

enum NetworkSession {
    
    static let api: URLSession = {
        let config = URLSessionConfiguration.default
        
        config.timeoutIntervalForRequest = 15
        
        config.timeoutIntervalForResource = 60
                
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "User-Agent": "swift-networking/1.0"
        ]
        
        config.requestCachePolicy = .useProtocolCachePolicy
        config.urlCache = URLCache(
            memoryCapacity: 10 * 1024 * 1024,
            diskCapacity: 50 * 1024 * 1024,
        )
        
        config.allowsCellularAccess = true
        config.allowsConstrainedNetworkAccess = true
        
        return URLSession(configuration: config)
    } ()
}
