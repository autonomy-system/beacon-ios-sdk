//
//  PermissionV2TezosResponse.swift
//
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
import BeaconCore
    
public struct PermissionV2TezosResponse: V2BeaconMessageProtocol {
    public let type: String
    public let version: String
    public let id: String
    public let senderID: String
    public let publicKey: String
    public let network: Tezos.Network
    public let scopes: [Tezos.Permission.Scope]
    
    public init(
        version: String = V2BeaconMessage<Tezos>.version,
        id: String,
        senderID: String,
        publicKey: String,
        network: Tezos.Network,
        scopes: [Tezos.Permission.Scope]
    ) {
        type = PermissionV2TezosResponse.type
        self.version = version
        self.id = id
        self.senderID = senderID
        self.publicKey = publicKey
        self.network = network
        self.scopes = scopes
    }
    
    // MARK: BeaconMessage Compatibility
    
    public init(from beaconMessage: BeaconMessage<Tezos>, senderID: String) throws {
        switch beaconMessage {
        case let .response(response):
            switch response {
            case let .permission(content):
                self.init(from: content, senderID: senderID)
            default:
                throw Beacon.Error.unknownBeaconMessage
            }
        default:
            throw Beacon.Error.unknownBeaconMessage
        }
    }
    
    public init(from beaconMessage: PermissionTezosResponse, senderID: String) {
        self.init(
            version: beaconMessage.version,
            id: beaconMessage.id,
            senderID: senderID,
            publicKey: beaconMessage.account.publicKey,
            network: beaconMessage.account.network,
            scopes: beaconMessage.scopes
        )
    }
    
    public func toBeaconMessage(
        withOrigin origin: Beacon.Connection.ID,
        andDestination destination: Beacon.Connection.ID,
        completion: @escaping (Result<BeaconMessage<Tezos>, Swift.Error>) -> ()
    ) {
        runCatching(completion: completion) {
            let address = try dependencyRegistry().extend().tezosWallet.address(fromPublicKey: publicKey)
            let accountID = try dependencyRegistry().identifierCreator.accountID(forAddress: address, onNetworkWithIdentifier: network.identifier)
            completion(.success(.response(
                .permission(
                    .init(
                        id: id,
                        version: version,
                        destination: destination,
                        account: .init(accountID: accountID, network: network, publicKey: publicKey, address: address),
                        scopes: scopes
                    )
                )
            )))
        }
    }
    
    // MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case type
        case version
        case id
        case senderID = "senderId"
        case publicKey
        case network
        case scopes
    }
}

extension PermissionV2TezosResponse {
    public static let type = "permission_response"
}
