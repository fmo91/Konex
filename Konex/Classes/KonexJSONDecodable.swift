//
//  KonexJSONDecodable.swift
//  Pods
//
//  Created by Fernando Ortiz on 2/1/17.
//
//

import Foundation

/**
 A protocol that transforms JSON objects to parsed objects.
 */
public protocol KonexJSONDecodable {
    static func instantiate(withJSON json: [String: Any]) -> Self?
}
