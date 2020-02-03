//
//  APIManager.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Moya
import RxSwift

class APIManager {
    
    static let shared = APIManager()
    
    #if PROD
    static private let plugins: [PluginType] = []
    #else
    static private let plugins: [PluginType] = [NetworkLoggerPlugin(verbose: true, cURL: true, responseDataFormatter: APIManager.JSONResponseDataFormatter)]
    #endif
    
    private let provider = MoyaProvider<APIService>(plugins: plugins)
    
    func fetchData(service: APIService) -> Single<Response> {
        return provider.rx.request(service)
    }
    
    static private func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data // fallback to original data if it can't be serialized.
        }
    }
}
