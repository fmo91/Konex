//
//  HTTPMethod.swift
//  Pods
//
//  Created by Fernando on 30/1/17.
//
//

import Foundation

public extension Konex {
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
}

