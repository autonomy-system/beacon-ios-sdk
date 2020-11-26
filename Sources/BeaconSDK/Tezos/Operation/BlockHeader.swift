//
//  Header.swift
//  TezosKit
//
//  Created by Mike Godenzi on 18.10.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation
    
extension Tezos.Operation {
    
    public struct BlockHeader: Codable, Equatable {
        public let level: Int
        public let proto: Int
        public let predecessor: String
        public let timestamp: Date
        public let validationPass: Int
        public let operationsHash: String
        public let fitness: [String]
        public let context: String
        public let priority: Int
        public let proofOfWorkNonce: String
        public let seedNonceHash: String?
        public let signature: String
        
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            level = try values.decode(Int.self, forKey: .level)
            proto = try values.decode(Int.self, forKey: .proto)
            predecessor = try values.decode(String.self, forKey: .predecessor)
            timestamp = try values.decode(Date.self, forKey: .timestamp)
            validationPass = try values.decode(Int.self, forKey: .validationPass)
            operationsHash = try values.decode(String.self, forKey: .operationsHash)
            fitness = try values.decode([String].self, forKey: .fitness)
            context = try values.decode(String.self, forKey: .context)
            // unfortunately, very early blocks do not have a priority field, even if the specs say it is required,
            // for this reason, we need to manually implement this initializer and handle the case where the priority is missing
            priority = (try values.decodeIfPresent(Int.self, forKey: .priority)) ?? 0
            proofOfWorkNonce = try values.decode(String.self, forKey: .proofOfWorkNonce)
            seedNonceHash = try values.decodeIfPresent(String.self, forKey: .seedNonceHash)
            signature = try values.decode(String.self, forKey: .signature)
        }
        
        public enum CodingKeys: String, CodingKey {
            case level
            case proto
            case predecessor
            case timestamp
            case validationPass = "validation_pass"
            case operationsHash = "operations_hash"
            case fitness
            case context
            case priority
            case proofOfWorkNonce = "proof_of_work_nonce"
            case seedNonceHash = "seed_nonce_hash"
            case signature
        }
    }
}
