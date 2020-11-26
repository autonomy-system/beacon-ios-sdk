//
//  MessageControllerProtocol.swift
//  BeaconSDK
//
//  Created by Julia Samol on 13.11.20.
//  Copyright © 2020 Papers AG. All rights reserved.
//

import Foundation

protocol MessageControllerProtocol {
    func onIncoming(
        _ message: Beacon.Message.Versioned,
        with origin: Beacon.Origin,
        completion: @escaping (Result<Beacon.Message, Error>) -> ()
    )
}
