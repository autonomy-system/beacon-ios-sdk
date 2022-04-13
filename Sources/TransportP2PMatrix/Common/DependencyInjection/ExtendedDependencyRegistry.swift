//
//  ExtendedDependencyRegistry.swift
//  
//
//  Created by Julia Samol on 27.09.21.
//

import Foundation
import BeaconCore

protocol ExtendedDependencyRegistry: DependencyRegistry {
    
    // MARK: P2P

    func p2pMatrixCommunicator(app: Beacon.Application) throws -> Transport.P2P.Matrix.Communicator
    func p2pMatrixSecurity(app: Beacon.Application) throws -> Transport.P2P.Matrix.Security
    func p2pMatrixStore(app: Beacon.Application, communicator: Transport.P2P.Matrix.Communicator, urlSession: URLSession, matrixNodes: [String]) throws -> Transport.P2P.Matrix.Store

    // MARK: Matrix

    func matrixClient(urlSession: URLSession) throws -> MatrixClient
}

extension DependencyRegistry {
    func extend() -> ExtendedDependencyRegistry {
        guard let extended = self as? ExtendedDependencyRegistry else {
            return P2PMatrixDependencyRegistry(dependencyRegistry: self)
        }
        
        return extended
    }
}
