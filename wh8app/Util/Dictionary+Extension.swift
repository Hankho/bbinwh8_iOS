//
//  Dictionary+Extension.swift
//  wh8app
//
//  Created by Gary Lin on 2019/8/5.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Foundation

extension Dictionary {
    
    func toData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
    
}
