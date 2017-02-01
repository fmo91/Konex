//
//  AuthenticatedRequest.swift
//  Konex
//
//  Created by Fernando Ortiz on 1/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Konex

class AuthenticatedRequest: KonexBasicRequest {
    override var parameters: [String : Any]? {
        return ["access_token": "An awesome token!"]
    }
}
