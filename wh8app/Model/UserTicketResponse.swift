//
//  UserTicketResponse.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/17.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

struct UserTicketResponse: Codable {
    var code: Int?
    var message: String?
    var userTicket: String?
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case message = "msg"
        case userTicket = "UserTicket"
    }
}
