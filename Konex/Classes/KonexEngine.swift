//
//  KonexEngine.swift
//  Pods
//
//  Created by Fernando Ortiz on 2/1/17.
//
//

import Foundation

/**
 KonexEngine contains the necessary logic to dispatch a request and getting a JSON result from it.
 */
public protocol KonexEngine {
    /**
     Dispatches a KonexRequest and returns a URLSessionDataTask, so it can be cancelled at any time.
     
     - parameter request: a KonexRequest to be dispatched
     - parameter onSuccess: a callback that get called when everything worked fine.
     - parameter onError: a callback that get called when something went wrong.
     - returns the URLSessionTask, because it assumes that you use URLSession at some point.
     */
    func dispatch(request: KonexRequest, onSuccess: @escaping (Any) -> Void, onError: @escaping  (Error) -> Void) -> URLSessionDataTask?
}
