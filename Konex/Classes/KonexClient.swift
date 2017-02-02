//
//  KonexClient.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation
import ObjectMapper

/**
 KonexClient is a class that is responsible for dispatching KonexRequests,
 optionally parsing json responses,
 and executing Konex Components at different times of request Life cycle.
 
 Example usage:
 
     let client = KonexClient()
     
     // GetUserRequest is a KonexRequest
     let request = GetUserRequest(withID: 3)
     
     
     client.requestObject(
         // User has to be a KonexJSONDecodable class or struct
         ofType: User.self,
         request: request,
         onSuccess: { (user: User) in
              // Please note that user is already parsed for you.
              // You are free! Do whatever you want with your user!
         },
         onError: { (error: Error) in
              // Oops! Something went wrong... you may want to handle this error yourself.
         }
     )
 
 */
open class KonexClient {
    
    // MARK: - Attributes -
    
    let engine: KonexEngine
    
    /**
     KonexClient has its own plugin collection that act
     after sending requests and after receiving responses
     */
    public var plugins = [KonexPlugin]()
    
    /**
     KonexClient has its own response processors collection that act
     after receiving a response and before firing responses handler plugins.
     */
    public var responseProcessors = [KonexResponseProcessor]()
    
    /**
     KonexClient has its own response validators collection that act
     after receiving a response
     */
    public var responseValidators = [KonexResponseValidator]()
    
    // MARK: - Init -
    
    /**
     By default, KonexClient relies on URLSession.shared,
     but you can inject any custom URLSession.
     
     @param urlSession custom URLSession that is used to perform Konex requests.
     */
    public init(engine: KonexEngine = Konex.URLSessionEngine()) {
        self.engine = engine
    }
    
    // MARK: - Requests dispatching -
    
    /**
     This is the main method in KonexClient
     
     Basically, using this method you can dispatch a KonexRequest via KonexEngine and receive a data
     response, or an error, that are handled by closures that you send to this method.
     
     request method also accept a collection of plugins, response processors and response validators.
     
     - parameter request: a KonexRequest, that is dispatched by KonexEngine.
     
     - parameter plugins: an array of KonexPlugin, that are executed after sending a request and after receiving a response.
     
     - parameter responseProcessors: an array of KonexResponseProcessor
     
     - parameter responseValidators: an array of KonexResponseValidator
     
     - parameter onSuccess: a closure that is executed with the received JSON, represented as Any.
     
     - parameter onError: a closure that is executed if anything went wrong. The error sent to this closure is of KonexError type, or any Error that can return after executing a KonexResponseValidator.
     
     - returns: a URLSessionDataTask, that you can use to cancel the request at any time.
     
     */
    @discardableResult
    open func request(request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping (Any) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        
        let plugins = localPlugins + request.requestPlugins + self.plugins
        let responseProcessors = localResponseProcessors + request.requestResponseProcessors + self.responseProcessors
        let responseValidators = localResponseValidators + request.requestResponseValidators + self.responseValidators
        
        let dataTask = engine.dispatch(
            request: request,
            onSuccess: { json in
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
            },
            onError: { error in
                onError(error)
            }
        )
        
        plugins.forEach { $0.didSendRequest(request) }
        
        return dataTask
    }
    
    /**
     Dispatches the KonexRequest using the KonexEngine and then parses the response using KonexJSONDecodable protocol to get an object of the given type.
     
     - parameter ofType: a KonexJSONDecodable type to transform the response JSON.
     
     - parameter request: a KonexRequest, that is then dispatched by KonexEngine.
     
     - parameter plugins: an array of KonexPlugin, that are executed after sending a request and after receiving a response.
     
     - parameter responseProcessors: an array of KonexResponseProcessor
     
     - parameter responseValidators: an array of KonexResponseValidator
     
     - parameter onSuccess: a closure that is executed with the received JSON, represented as Any.
     
     - parameter onError: a closure that is executed if anything went wrong. The error sent to this closure is of KonexError type, or any Error that can return after executing a KonexResponseValidator.
     
     - returns: a URLSessionDataTask, that you can use to cancel the request at any time.
     */
    @discardableResult
    open func requestObject<T:KonexJSONDecodable>(ofType type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping (T) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        return self.request(request: request,
            plugins: localPlugins,
            responseProcessors: localResponseProcessors,
            responseValidators: localResponseValidators,
            onSuccess: { response in
                guard let json = response as? [String: Any] else {
                    onError(KonexError.invalidParsing)
                    return
                }
                guard let parsedObject = T.instantiate(withJSON: json) else {
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
    
    /**
     Dispatches the KonexRequest using the KonexEngine and then parses the response using KonexJSONDecodable protocol to get an array of the given type.
     
     - parameter of: a KonexJSONDecodable type to transform the response JSON.
     
     - parameter request: a KonexRequest, that is dispatched via KonexEngine.
     
     - parameter plugins: an array of KonexPlugin, that are executed after sending a request and after receiving a response.
     
     - parameter responseProcessors: an array of KonexResponseProcessor
     
     - parameter responseValidators: an array of KonexResponseValidator
     
     - parameter onSuccess: a closure that is executed with the received JSON, represented as Any.
     
     - parameter onError: a closure that is executed if anything went wrong. The error sent to this closure is of KonexError type, or any Error that can return after executing a KonexResponseValidator.
     
     - returns: a URLSessionDataTask, that you can use to cancel the request at any time.
     */
    @discardableResult
    open func requestArray<T: KonexJSONDecodable>(of type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping ([T]) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        
        return self.request(request: request,
            plugins: localPlugins,
            responseProcessors: localResponseProcessors,
            responseValidators: localResponseValidators,
            onSuccess: { response in
                guard let jsonArray = response as? [[String:Any]] else {
                    onError(KonexError.invalidParsing)
                    return
                }
                let parsedArray = jsonArray.flatMap(T.instantiate)
                
                onSuccess(parsedArray)
            },
            onError: { error in
                onError(error)
            }
        )
    }
}

