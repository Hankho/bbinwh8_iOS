//
//  APIService.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Moya

enum APIService {
    case GetSiteInfo(String)
    case GetSessionStatus(String, String)
    case GetUserTicket(String, String, String)
}

extension APIService: TargetType {
    var baseURL: URL {
        switch self {
        case .GetSessionStatus(let homeAddress, _):
            return URL(string: homeAddress)!
        case .GetUserTicket(let homeAddress, _, _):
            return URL(string: homeAddress)!
        default:
            return URL(string: "https://app.wynn660.net")!
        }
    }
    
    var path: String {
        switch self {
        case .GetSiteInfo(let siteID):
            return "/GetSiteInfo/ios/\(siteID)"
        case .GetSessionStatus:
            return "/WebAPI/GetSessionStatus"
        case .GetUserTicket:
            return "/WebAPI/GetUserTicket"
        }
    }
    
    var method: Method {
        switch self {
        case .GetSiteInfo:
            return .get
        case .GetSessionStatus, .GetUserTicket:
            return .post
        }
    }
    
    var sampleData: Data {
        switch self {
        case .GetSiteInfo:
            return "GetSiteInfo".utf8Encoded
        case .GetSessionStatus(let homeAddress, let token):
            return "{\"homeAddress\": \(homeAddress), \"token\": \(token)}".utf8Encoded
        case .GetUserTicket(let homeAddress, let userId, let token):
            return "{\"homeAddress\": \(homeAddress), \"userid\": \(userId), \"token\": \(token)}".utf8Encoded
        }
    }
    
    var task: Task {
        switch self {
        case .GetSessionStatus(_, let token):
            return .requestParameters(parameters: ["faticket": token],
                                      encoding: URLEncoding.default)
            
        case .GetUserTicket(_, let userId, let token):
            return .requestParameters(parameters: ["userid": userId, "usertoken": token],
                                      encoding: URLEncoding.default)
            
        default:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/x-www-form-urlencoded",
                "Sign": "123456"]
    }
}

// MARK: - Helpers
private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
