//
//  Beacon.swift
//
//
//  Created by Julia Samol on 10.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

public class Beacon {

    public enum ApplicationType {
        case wallet
        case dapp
    }

    public private(set) static var shareds = [ApplicationType: Beacon]()
    public static var shared: Beacon? { shareds[.wallet] }
    public static var dappShared: Beacon? { shareds[.dapp] }

    public let dependencyRegistry: DependencyRegistry
    public let app: Application
    
    public var beaconID: String {
        HexString(from: app.keyPair.publicKey).asString()
    }
    
    private init(dependencyRegistry: DependencyRegistry, app: Application) {
        self.dependencyRegistry = dependencyRegistry
        self.app = app
    }
    
    // MARK: Initialization
    
    public static func initialize(
        appType: ApplicationType,
        appName: String,
        appIcon: String?,
        appURL: String?,
        blockchainFactories: [BlockchainFactory],
        storage: Storage,
        secureStorage: SecureStorage,
        completion: @escaping (Result<(Beacon), Swift.Error>) -> ()
    ) {
        if let beacon = shareds[appType] {
            completion(.success(beacon))
            return
        }
        
        let dependencyRegistry = CoreDependencyRegistry(blockchainFactories: blockchainFactories, storage: storage, secureStorage: secureStorage)
        Beacon.initialize(appType: appType, appName: appName, appIcon: appIcon, appURL: appURL, dependencyRegistry: dependencyRegistry, completion: completion)
    }
    
    static func initialize(
        appType: ApplicationType,
        appName: String,
        appIcon: String?,
        appURL: String?,
        dependencyRegistry: DependencyRegistry,
        completion: @escaping (Result<(Beacon), Swift.Error>) -> ()
    ) {
        if let beacon = shareds[appType] {
            completion(.success(beacon))
            return
        }
        
        let crypto = dependencyRegistry.crypto
        let storageManager = dependencyRegistry.storageManager
        
        Compat.initialize(with: dependencyRegistry)
        
        setSDKVersion(savedWith: storageManager) { result in
            guard result.isSuccess(else: completion) else { return }
            
            self.loadOrGenerateKeyPair(using: crypto, savedWith: storageManager) { result in
                guard let keyPair = result.get(ifFailure: completion) else { return }
                let beacon = Beacon(
                    dependencyRegistry: dependencyRegistry,
                    app: Application(keyPair: keyPair, name: appName, icon: appIcon, url: appURL)
                )
                shareds[appType] = beacon
                
                completion(.success(beacon))
            }
        }
    }
    
    private static func setSDKVersion(savedWith storage: StorageManager, completion: @escaping (Result<(), Swift.Error>) -> ()) {
        storage.setSDKVersion(Beacon.Configuration.sdkVersion, completion: completion)
    }
    
    private static func loadOrGenerateKeyPair(
        using crypto: Crypto,
        savedWith storageManager: StorageManager,
        completion: @escaping (Result<KeyPair, Swift.Error>) -> ()
    ) {
        storageManager.getSDKSecretSeed { result in
            guard let storageSeed = result.get(ifFailure: completion) else { return }
            
            if let seed = storageSeed {
                completion(runCatching { try crypto.keyPairFrom(seed: seed) })
            } else {
                self.generateKeyPair(using: crypto, savedWith: storageManager, completion: completion)
            }
        }
    }
    
    private static func generateKeyPair(
        using crypto: Crypto,
        savedWith storageManager: StorageManager,
        completion: @escaping (Result<KeyPair, Swift.Error>) -> ()
    ) {
        do {
            let seed = try crypto.guid()
            storageManager.setSDKSecretSeed(seed) { result in
                guard result.isSuccess(else: completion) else { return }
                
                completion(runCatching { try crypto.keyPairFrom(seed: seed) })
            }
        } catch {
            completion(.failure(error))
        }
    }

    public func openCryptoBox(payload: String, completion: @escaping (Result<[UInt8], Swift.Error>) -> ()) {
        do {
            let hexString = try HexString(from: payload)

            let keyPair = app.keyPair
            let decryptedMessage = try dependencyRegistry.crypto.decrypt(message: hexString, publicKey: keyPair.publicKey, secretKey: keyPair.secretKey)
            completion(.success(decryptedMessage))
        } catch {
            completion(.failure(error))
        }
    }

    public func sealCryptoBox(payload: String, publicKey: String, completion: @escaping (Result<String, Swift.Error>) -> ()) {
        do {
            let pubicKeyHex = try HexString(from: publicKey).asBytes()
            let keyPair = app.keyPair
            let sharedKey = try dependencyRegistry.crypto.clientSessionKeyPair(publicKey: pubicKeyHex, secretKey: keyPair.secretKey)

            let encryptedData = try dependencyRegistry.crypto.encrypt(message: payload, withSharedKey: sharedKey.tx)
            let hexString = HexString(from: encryptedData)
            completion(.success(hexString.asString()))
        } catch {
            completion(.failure(error))
        }
    }

    public func openCryptoBox(payload: String, publicKey: String, completion: @escaping (Result<[UInt8], Swift.Error>) -> ()) {
        do {
            let publicKeyBytes = try HexString(from: publicKey).asBytes()
            let keyPair = app.keyPair
            let sharedKey = try dependencyRegistry.crypto.serverSessionKeyPair(publicKey: publicKeyBytes, secretKey: keyPair.secretKey)

            let decryptedData = try dependencyRegistry.crypto.decrypt(message: HexString(from: payload), withSharedKey: sharedKey.rx)
            completion(.success(decryptedData))

        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: Extensions

extension Beacon {
    
    static func reset() {
        shareds = [:]
    }
}
