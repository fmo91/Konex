//
//  URLSessionKonexEngine.swift
//  Pods
//
//  Created by Fernando Ortiz on 2/1/17.
//
//

import Foundation

public extension Konex {
    /**
     The default KonexEngine. Dispatches KonexRequest using only URLSession.
     */
    public struct URLSessionEngine: KonexEngine {
        
        public let urlSession: URLSession
        
        public init(urlSession: URLSession = .shared) {
            self.urlSession = urlSession
        }
        
        private func buildUrlRequest(from konexRequest: KonexRequest) throws -> URLRequest {
            guard let url = URL(string: finalPath(from: konexRequest)) else {
                throw KonexError.invalidURL
            }
            
            var request = URLRequest(url: url)
            
            request.httpBody = try httpBody(from: konexRequest)
            request.allHTTPHeaderFields = konexRequest.headers
            request.httpMethod = konexRequest.method.rawValue
            
            return request
        }
        
        private func finalPath(from request: KonexRequest) -> String {
            switch request.method {
            case .get:
                guard let parameters = request.parameters else {
                    return request.path
                }
                
                var pathExtension = ""
                for (key, value) in parameters {
                    let connector = pathExtension.isEmpty ? "?" : "&"
                    pathExtension.append("\(connector)\(key)=\(value)")
                }
                return "\(request.path)\(pathExtension)"
                
            default:
                return request.path
            }
        }
        
        private func httpBody(from request: KonexRequest) throws -> Data? {
            guard let parameters = request.parameters else {
                return nil
            }
            
            guard let body = try? JSONSerialization.data(withJSONObject: request.parameters, options: JSONSerialization.WritingOptions.prettyPrinted) else {
                throw KonexError.invalidParameters
            }
            
            return body
        }
        
        public func dispatch(request: KonexRequest, onSuccess: @escaping (Any) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
            
            do {
                let urlRequest = try buildUrlRequest(from: request)
                let dataTask = urlSession.dataTask(with: urlRequest, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
                    
                    if let error = error {
                        onError(KonexError.wrongResponse(error))
                        return
                    }
                    
                    guard let _data = data else {
                        onError(KonexError.emptyResponse)
                        return
                    }
                    
                    guard let json = try? JSONSerialization.jsonObject(with: _data, options: JSONSerialization.ReadingOptions.allowFragments) else {
                        onError(KonexError.invalidResponse)
                        return
                    }
                    
                    onSuccess(json)
                })
                
                dataTask.resume()
                
                return dataTask
            } catch let error {
                onError(error)
                return nil
            }
        }
    }
}
