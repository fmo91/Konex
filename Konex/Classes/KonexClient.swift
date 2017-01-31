//
//  KonexClient.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation
import RxSwift
import ObjectMapper
import RxObjectMapper

public final class KonexClient {
    
    let urlSession: URLSession
    
    public var plugins = [KonexPlugin]()
    public var responseProcessors = [KonexResponseProcessor]()
    public var responseValidators = [KonexResponseValidator]()
    
    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    private func dispatch(request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = [], onSuccess: @escaping (Any) -> Void, onError: @escaping (Error) -> Void) -> URLSessionDataTask? {
        
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
    
    public func request(_ request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = []) -> Observable<Any> {
        return .create { observer in
            let task = self.dispatch(request: request,
                onSuccess: { json in
                    observer.onNext(json)
                    observer.onCompleted()
                },
                onError: { error in
                    observer.onError(error)
                }
            )
            
            return Disposables.create {
                task?.cancel()
            }
        }
    }
    
    public func requestObject<T:Mappable>(ofType type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = []) -> Observable<T> {
        return self.request(request).mapObject(type: type)
    }
    
    public func requestArray<T: Mappable>(of type: T.Type, request: KonexRequest, plugins localPlugins: [KonexPlugin] = [], responseProcessors localResponseProcessors: [KonexResponseProcessor] = [], responseValidators localResponseValidators: [KonexResponseValidator] = []) -> Observable<[T]> {
        return self.request(request).mapArray(type: type)
    }
}
