//
//  Error.swift
//  Pods
//
//  Created by Fernando on 30/1/17.
//
//

import Foundation

enum KonexError: Error {
    case invalidURL
    case invalidParameters
    case wrongResponse(Error)
    case emptyResponse
    case invalidResponse
    case invalidParsing
}
