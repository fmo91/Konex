//
//  KonexPlugin.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation

/**
 A Konex plugin can define methods that are called during the
 KonexRequest life cycle.
 */
public protocol KonexPlugin {
    /**
     didSendRequest is called after the KonexRequest has been dispatched.
     */
    func didSendRequest(_ request: KonexRequest)
    
    /**
     didReceiveResponse is called after the response comes and has been validated.
     */
    func didReceiveResponse(_ response: Any, from request: KonexRequest)
}

// MARK: - Default implementations -
public extension KonexPlugin {
    func didSendRequest(_ request: KonexRequest) {}
    func didReceiveResponse(_ response: Any, from request: KonexRequest) {}
}
