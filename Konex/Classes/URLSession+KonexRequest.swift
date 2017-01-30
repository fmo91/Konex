//
//  URLSession+KonexRequest.swift
//  Pods
//
//  Created by Fernando on 30/1/17.
//
//

import RxSwift
import RxCocoa

internal extension Reactive where Base: URLSession {
    
    func json(konexRequest: KonexRequest) -> Observable<Any> {
        do {
            let urlRequest = try konexRequest.urlRequest()
            return URLSession.shared.rx.json(request: urlRequest)
        } catch let error {
            return .error(error)
        }
    }
    
}
