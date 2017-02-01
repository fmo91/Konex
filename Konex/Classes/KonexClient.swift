//
//  KonexClient.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation
import ObjectMapper

public extension Konex {
    
    /**
     Konex.Client is a class that is responsible for dispatching KonexRequests,
     optionally parsing json responses (currently using ObjectMapper),
     and executing Konex Components at different times of request Life cycle.
     
     Example usage:
     
         let client = Konex.Client()
         
         // GetUserRequest is a KonexRequest
         let request = GetUserRequest(withID: 3)
         
         
         client.requestObject(
             // User has to be a Mappable class or struct
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
    open class Client {
        
        // MARK: - Attributes -
        
        /**
         Konex.Client relies on URLSession for performing requests.
         */
        let urlSession: URLSession
        
        /**
         Konex.Client has its own plugin collection that act
         after sending requests and after receiving responses
         */
        public var plugins = [KonexPlugin]()
        
        /**
         Konex.Client has its own response processors collection that act
         after receiving a response and before firing responses handler plugins.
         */
        public var responseProcessors = [KonexResponseProcessor]()
        
        /**
         Konex.Client has its own response validators collection that act
         after receiving a response
         */
        public var responseValidators = [KonexResponseValidator]()
        
        // MARK: - Init -
        
        /**
         By default, Konex.Client relies on URLSession.shared,
         but you can inject any custom URLSession.
         
         @param urlSession custom URLSession that is used to perform Konex requests.
         */
        public init(urlSession: URLSession = .shared) {
            self.urlSession = urlSession
        }
        
        // MARK: - Requests dispatching -
        
        /**
         This is the main method in Konex.Client
         
         Basically, using this method you can dispatch a KonexRequest and receive a data
         response, or an error, that are handled by closures that you send to this method.
         
         request method also accept a collection of plugins, response processors and response validators.
         
         - parameter request: a KonexRequest, that is converted to a URLRequest and then dispatched.
         
         - parameter plugins: an array of KonexPlugin, that are executed after sending a request and after receiving a response.
         
         - parameter responseProcessors: an array of KonexResponseProcessor
         
         - parameter responseValidators: an array of KonexResponseValidator
         
         - parameter onSuccess: a closure that is executed with the received JSON, represented as Any.
         
         - parameter onError: a closure that is executed if anything went wrong. The error sent to this closure is of KonexError type, or any Error that can return after executing a KonexResponseValidator.
         
         - returns: a URLSessionDataTask, that you can use to cancel the request at any time.
         
         */
        @discardableResult
        open func request(request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping (Any) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
            
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
        
        /**
         Dispatches the KonexRequest using the urlSession and then parses the response using ObjectMapper to get an object of the given type.
         
         - parameter ofType: a Mappable type to transform the response JSON.
         
         - parameter request: a KonexRequest, that is converted to a URLRequest and then dispatched.
         
         - parameter plugins: an array of KonexPlugin, that are executed after sending a request and after receiving a response.
         
         - parameter responseProcessors: an array of KonexResponseProcessor
         
         - parameter responseValidators: an array of KonexResponseValidator
         
         - parameter onSuccess: a closure that is executed with the received JSON, represented as Any.
         
         - parameter onError: a closure that is executed if anything went wrong. The error sent to this closure is of KonexError type, or any Error that can return after executing a KonexResponseValidator.
         
         - returns: a URLSessionDataTask, that you can use to cancel the request at any time.
         */
        @discardableResult
        open func requestObject<T:Mappable>(ofType type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping (T) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
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
        
        /**
         Dispatches the KonexRequest using the urlSession and then parses the response using ObjectMapper to get an array of the given type.
         
         - parameter of: a Mappable type to transform the response JSON.
         
         - parameter request: a KonexRequest, that is converted to a URLRequest and then dispatched.
         
         - parameter plugins: an array of KonexPlugin, that are executed after sending a request and after receiving a response.
         
         - parameter responseProcessors: an array of KonexResponseProcessor
         
         - parameter responseValidators: an array of KonexResponseValidator
         
         - parameter onSuccess: a closure that is executed with the received JSON, represented as Any.
         
         - parameter onError: a closure that is executed if anything went wrong. The error sent to this closure is of KonexError type, or any Error that can return after executing a KonexResponseValidator.
         
         - returns: a URLSessionDataTask, that you can use to cancel the request at any time.
         */
        @discardableResult
        open func requestArray<T: Mappable>(of type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping ([T]) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
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
}

