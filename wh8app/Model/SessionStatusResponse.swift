//
//  SessionStatusResponse.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/17.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

struct SessionStatusResponse: Codable {
    var userId: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "userid"
    }
}
