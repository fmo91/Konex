//
//  KonexBaseRequest.swift
//  Pods
//
//  Created by Fernando Ortiz on 1/31/17.
//
//

import Foundation

/**
 KonexBaseRequest is intended to be the base class of your requests. It doesn't
 make sense by itself, so you can think on this as it was an abstract class.
 
 This class is open, so you can override any property on it when subclassing.
 
 **Note:** Using this class is not required. You can model your requests in a
 more shiny, protocol-oriented fashion by only using KonexRequest and value types,
 but this can be very useful in some kinds of application, when having a "Base request"
 is worth it.
 */
open class KonexBaseRequest: KonexRequest {
    open var requestPlugins: [KonexPlugin] { return [] }
    open var requestResponseProcessors: [KonexResponseProcessor] { return [] }
    open var requestResponseValidators: [KonexResponseValidator] { return [] }
    
    open var path: String { return "" }
    open var method: Konex.HTTPMethod { return .get }
    open var parameters: [String : Any]? { return [:] }
    open var headers: [String : String]? { return [:] }
    
    public init() {}
}
