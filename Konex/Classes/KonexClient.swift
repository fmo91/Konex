//
//  KonexClient.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation
import ObjectMapper

public final class KonexClient {
    
    let urlSession: URLSession
    
    public var plugins = [KonexPlugin]()
    public var responseProcessors = [KonexResponseProcessor]()
    public var responseValidators = [KonexResponseValidator]()
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    @discardableResult
    public func request(request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping (Any) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        
        let plugins = self.plugins + localPlugins + request.requestPlugins
        let responseProcessors = self.responseProcessors + localResponseProcessors + request.requestResponseProcessors
        let responseValidators = self.responseValidators + localResponseValidators + request.requestResponseValidators
        
        do {
            let urlRequest = try request.urlRequest()
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
                
                plugins.forEach { $0.didReceiveResponse(json, from: request) }
                
                for validator in responseValidators {
                    do {
                        try validator.validate(response: json)
                    } catch let error {
                        onError(error)
                        return
                    }
                }
                
                var processedResponse = json
                
                for processor in responseProcessors {
                    processedResponse = processor.process(response: processedResponse)
                }
                
                onSuccess(processedResponse)
            })
            
            plugins.forEach { $0.didSendRequest(request) }
            
            dataTask.resume()
            
            return dataTask
        } catch let error {
            onError(error)
            return nil
        }
    }
    
    @discardableResult
    public func requestObject<T:Mappable>(ofType type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping (T) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        let mapper = Mapper<T>()
        
        return self.request(request: request,
            plugins: localPlugins,
            responseProcessors: localResponseProcessors,
            responseValidators: localResponseValidators,
            onSuccess: { response in
                guard let parsedObject = mapper.map(JSONObject: response) else {
                    onError(KonexError.invalidParsing)
                    return
                }
                onSuccess(parsedObject)
            },
            onError: { error in
                onError(error)
            }
        )
    }
    
    @discardableResult
    public func requestArray<T: Mappable>(of type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping ([T]) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        let mapper = Mapper<T>()
        
        return self.request(request: request,
            plugins: localPlugins,
            responseProcessors: localResponseProcessors,
            responseValidators: localResponseValidators,
            onSuccess: { response in
                guard let parsedArray = mapper.mapArray(JSONObject: response) else {
                    onError(KonexError.invalidParsing)
                    return
                }
                onSuccess(parsedArray)
            },
            onError: { error in
                onError(error)
            }
        )
    }
}
