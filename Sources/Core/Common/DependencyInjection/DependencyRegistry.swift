//
//  DependencyRegistry.swift
//
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public protocol DependencyRegistry {
    
    // MARK: Storage
    
    var storageManager: StorageManager { get }
    
    // MARK: Controller
    
    func connectionController(configuredWith connections: [Beacon.Connection], app: Beacon.Application) throws -> ConnectionControllerProtocol
    var messageController: MessageControllerProtocol { get }
    
    // MARK: Transport
    
    func transport(configuredWith connection: Beacon.Connection, app: Beacon.Application) throws -> Transport
    
    // MARK: Coin
    
    var blockchainRegistry: BlockchainRegistryProtocol { get }
    
    // MARK: Crypto
    
    var crypto: Crypto { get }
    
    
    // MARK: Serializer
    
    var serializer: Serializer { get }
    
    // MARK: Network
    
    func http(urlSession: URLSession) -> HTTP
    
    // MARK: Migration
    
    var migration: Migration { get }
    
    // MARK: Other
    
    var identifierCreator: IdentifierCreatorProtocol { get }
    var time: TimeProtocol { get }
}
