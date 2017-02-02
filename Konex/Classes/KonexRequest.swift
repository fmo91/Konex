//
//  KonexRequest.swift
//  Pods
//
//  Created by Fernando on 30/1/17.
//
//

import Foundation

/**
 KonexRequest is the request protocol that your requests has to implement
 in order to be dispatched by the KonexClient via KonexEngine
 */
public protocol KonexRequest {
    var requestPlugins: [KonexPlugin] { get }
    var requestResponseProcessors: [KonexResponseProcessor] { get }
    var requestResponseValidators: [KonexResponseValidator] { get }
    
    var path: String { get }
    var method: Konex.HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
}

// MARK: - Default implementations -
public extension KonexRequest {
    var requestPlugins: [KonexPlugin] { return [] }
    var requestResponseProcessors: [KonexResponseProcessor] { return [] }
    var requestResponseValidators: [KonexResponseValidator] { return [] }
    
    var method: Konex.HTTPMethod { return .get }
    var parameters: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }
}
