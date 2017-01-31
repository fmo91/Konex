//
//  KonexResponseValidator.swift
//  Pods
//
//  Created by Fernando on 31/1/17.
//
//

import Foundation

public protocol KonexResponseValidator {
    func validate(response: Any) throws
}
