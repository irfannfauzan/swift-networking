//
//  NetworkMonitor.swift
//  swift-networking
//
//  Created by Vokal-Ican on 24/10/26.
//

import Network

final class NetworkMonitor {
    
    //MARK: Singleton
    
    static let shared = NetworkMonitor()
    
    //MARK: Properties
    
    private let monitor = NWPathMonitor()
    
    private let queue = DispatchQueue(label: "com.app.networkmonitor")
    
    private(set) var isConnected = true
    
    private(set) var isUsingCellular = false
        
    var onStatusChange: ((Bool) -> Void)?
    
    private init() {}
    
    func start() {
        
        monitor.pathUpdateHandler = { [weak self] path in
            
            //Connected to internet
            
            let connected = path.status == .satisfied
            
            let usingCellular = path.usesInterfaceType(.cellular)
            
            DispatchQueue.main.async {
                self?.isConnected = connected
                self?.isUsingCellular = usingCellular
                self?.onStatusChange?(connected)
            }
        }
        
        monitor.start(queue: queue)
    }
    
    func stop() {
        monitor.cancel()
    }
}
