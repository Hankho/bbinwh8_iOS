//
//  AppUtil.swift
//  base
//
//  Created by Gary Lin on 2019/8/5.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Foundation

class AppUtil {
    
    static var bundleId: String {
        get {
            return Bundle.main.bundleIdentifier!
        }
    }
    
    static var targetId: String {
        get {
            return bundleId.components(separatedBy: ".")[1]
        }
    }
    
}
