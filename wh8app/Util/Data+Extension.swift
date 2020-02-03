//
//  Data+Extension.swift
//  wh8app
//
//  Created by Gary Lin on 2019/8/5.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Foundation

extension Data {
    
    func toDictionary<T>() -> [String: T] {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as! [String: T]
    }
    
}
