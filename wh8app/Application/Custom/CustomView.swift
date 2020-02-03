//
//  CustomView.swift
//  wh8app
//
//  Created by Gary Lin on 2019/8/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import UIKit

class CustomView: UIView {
    
    // Override the default safe area to reduce the botom inset
    override var safeAreaInsets: UIEdgeInsets {
        get {
            let inset = super.safeAreaInsets
            let newBottom = CGFloat(inset.bottom > 0 ? 12 : 0)
            return UIEdgeInsets(top: inset.top, left: inset.left, bottom: newBottom, right: inset.right)
        }
    }
    
}
