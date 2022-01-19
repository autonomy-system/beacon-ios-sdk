//
//  P2PMatrixDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

class P2PMatrixDependencyRegistry: ExtendedDependencyRegistry {
    private let dependencyRegistry: DependencyRegistry
    
    init(dependencyRegistry: DependencyRegistry) {
        self.dependencyRegistry = dependencyRegistry
    }
    
    // MARK: P2P
    
    func p2pMatrixCommunicator(app: Beacon.Application) throws -> Transport.P2P.Matrix.Communicator {
        Transport.P2P.Matrix.Communicator(app: app, crypto: self.crypto)
    }
    
    func p2pMatrixSecurity(app: Beacon.Application) throws -> Transport.P2P.Matrix.Security {
        Transport.P2P.Matrix.Security(app: app, crypto: self.crypto, time: self.time)
    }
    
    func p2pMatrixStore(app: Beacon.Application, communicator: Transport.P2P.Matrix.Communicator, urlSession: URLSession, matrixNodes: [String]) throws -> Transport.P2P.Matrix.Store {
        Transport.P2P.Matrix.Store(
            app: app,
            communicator: communicator,
            matrixClient: matrixClient(urlSession: urlSession),
            matrixNodes: matrixNodes,
            storageManager: storageManager,
            migration: migration
        )
    }
    
    // MARK: Matrix
    
    func matrixClient(urlSession: URLSession) -> MatrixClient {
        let http = self.http(urlSession: urlSession)
        
        return MatrixClient(
            store: MatrixClient.Store(storageManager: storageManager),
            nodeService: MatrixClient.NodeService(http: http),
            userService: MatrixClient.UserService(http: http),
            eventService: MatrixClient.EventService(http: http),
            roomService: MatrixClient.RoomService(http: http),
            time: time
        )
    }
    
    // MARK: Derived
    
    var storageManager: StorageManager { dependencyRegistry.storageManager }
    
    func connectionController(configuredWith connections: [Beacon.Connection], app: Beacon.Application) throws -> ConnectionControllerProtocol {
        try dependencyRegistry.connectionController(configuredWith: connections, app: app)
    }
    
    var messageController: MessageControllerProtocol { dependencyRegistry.messageController }
    
    func transport(configuredWith connection: Beacon.Connection, app: Beacon.Application) throws -> Transport {
        try dependencyRegistry.transport(configuredWith: connection, app: app)
    }
    
    var blockchainRegistry: BlockchainRegistryProtocol { dependencyRegistry.blockchainRegistry }
    var crypto: Crypto { dependencyRegistry.crypto }
    var serializer: Serializer { dependencyRegistry.serializer }
    
    func http(urlSession: URLSession) -> HTTP {
        dependencyRegistry.http(urlSession: urlSession)
    }
    
    var migration: Migration {
        dependencyRegistry.migration.register([
            Migration.P2PMatrix.From1_0_4(storageManager: self.storageManager)
        ])
        
        return dependencyRegistry.migration
    }
    
    var identifierCreator: IdentifierCreatorProtocol { dependencyRegistry.identifierCreator }
    var time: TimeProtocol { dependencyRegistry.time }
}
