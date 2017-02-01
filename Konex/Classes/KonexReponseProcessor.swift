//
//  KonexReponseProcessor.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation

/**
 A KonexResponseProcessor can be used if you want to transform the response in some 
 way after being parsed or returned.
 
 Using KonexResponseProcessors objects, the KonexClient builds a functional pipeline
 in which the response is transformed.
 */
public protocol KonexResponseProcessor {
    
    /**
     Pure function in which the response gets transformed in some other object
     and then returned.
     */
    func process(response: Any) -> Any
}
