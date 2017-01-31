//
//  KonexPlugin.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation

public protocol KonexPlugin {
    func didSendRequest(_ request: KonexRequest)
    func didReceiveResponse(_ response: Any, from request: KonexRequest)
}
