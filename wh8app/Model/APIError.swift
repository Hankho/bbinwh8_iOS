//
//  APIError.swift
//  wh8app
//
//  Created by Gary Lin on 2019/8/6.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Foundation

struct APIError: Error {
    
    var reason: String
    var description: String
    var userInfo: Any
    
    init(reason: String, description: String, userInfo: Any) {
        self.reason = reason
        self.description = description
        self.userInfo = userInfo
    }
    
}
