//
//  GetAllUsersRequest.swift
//  Konex
//
//  Created by Fernando Ortiz on 1/31/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import Konex

final class GetAllUsersRequest: AuthenticatedRequest {
    override var path: String {
        return ""
    }
    
    override var parameters: [String : Any]? {
        var params = super.parameters
        params?["something"] = "anything"
        return params
    }
}
