//
//  KonexReponseProcessor.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation

public protocol KonexResponseProcessor {
    func process(response: Any) -> Any
}
