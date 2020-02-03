//
//  SiteInfoResponse.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

struct SiteInfoResponse: Codable {
    var apiVersion: Double
    var homeAddress: String
    var chatAddress: String?
    var loginAddress: String
    var downloadPath: String
    
    enum CodingKeys: String, CodingKey {
        case apiVersion = "ApiVersion"
        case homeAddress = "HomeAddress"
        case chatAddress = "ChatAddress"
        case loginAddress = "LoginAddress"
        case downloadPath = "DownloadPath"
    }
}
