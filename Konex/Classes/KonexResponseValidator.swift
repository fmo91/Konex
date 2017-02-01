//
//  KonexResponseValidator.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation

/**
 KonexResponseValidator validates if a response is correct or not.
 If it isn't correct, then an Error is thrown.
 */
public protocol KonexResponseValidator {
    func validate(response: Any) throws
}
