//
//  HTTPMethod.swift
//  Pods
//
//  Created by Fernando on 30/1/17.
//
//

import Foundation

public extension Konex {
    
    /**
     HTTPMethod defines the methods
     that are used when dispatching requests.
     */
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}

