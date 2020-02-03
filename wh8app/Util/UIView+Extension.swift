//
//  UIView+Extension.swift
//  tetrapods-dev
//
//  Created by Gary Lin on 2019/7/26.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import UIKit

extension UIView {
    
    func fadeIn(duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        self.alpha = 0
        self.isHidden = false
        UIView.animate(
            withDuration: duration,
            animations:{ [weak self] in
                self?.alpha = 1
            },
            completion: { (_) in
                onCompletion?()
        })
    }
    
    func fadeOut(duration: TimeInterval = 0.2, onCompletion: (() -> Void)? = nil) {
        UIView.animate(
            withDuration: duration,
            animations: { [weak self] in
                self?.alpha = 0
            },
            completion: { [weak self] (_) in
                self?.isHidden = true
                onCompletion?()
        })
    }
    
}
