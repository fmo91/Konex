//
//  KonexRequest.swift
//  Pods
//
//  Created by Fernando on 30/1/17.
//
//

import Foundation

public protocol KonexRequest {
    var requestPlugins: [KonexPlugin] { get }
    var requestResponseProcessors: [KonexResponseProcessor] { get }
    var requestResponseValidators: [KonexResponseValidator] { get }
    
    var path: String { get }
    var method: Konex.HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
}

public extension KonexRequest {
    var requestPlugins: [KonexPlugin] { return [] }
    var requestResponseProcessors: [KonexResponseProcessor] { return [] }
    var requestResponseValidators: [KonexResponseValidator] { return [] }
    
    var method: Konex.HTTPMethod { return .get }
    var parameters: [String: Any]? { return nil }
    var headers: [String: String]? { return nil }
}

internal extension KonexRequest {
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: finalPath) else {
            throw KonexError.invalidURL
        }
        
        var request = URLRequest(url: url)
        
        request.httpBody = try httpBody()
        request.allHTTPHeaderFields = headers
        request.httpMethod = method.rawValue
        
        return request
    }
    
    var finalPath: String {
        switch method {
        case .get:
            guard let parameters = parameters else {
                return path
            }
            
            var pathExtension = ""
            for (key, value) in parameters {
                let connector = pathExtension.isEmpty ? "?" : "&"
                pathExtension.append("\(connector)\(key)=\(value)")
            }
            return "\(path)\(pathExtension)"
            
        default:
            return path
        }
    }
    
    func httpBody() throws -> Data? {
        guard let parameters = self.parameters else {
            return nil
        }
        
        guard let body = try? JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            throw KonexError.invalidParameters
        }
        
        return body
    }
}
