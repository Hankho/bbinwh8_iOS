//
//  BaseViewController.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController {
    
    // Dispose bag for observables
    let disposeBag = DisposeBag()
    
    func showAlert(title: String? = nil, message: String?, actions: [UIAlertAction]? = nil) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        showAlertController(alertCtrl, actions: actions)
    }
    
    func showActionSheet(title: String? = nil, message: String?, actions: [UIAlertAction]? = nil) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        showAlertController(alertCtrl, actions: actions)
    }
    
    func showInputAlert(title: String? = nil, message: String?, actions: [UIAlertAction]? = nil, handler: ((UITextField) -> Void)? = nil) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertCtrl.addTextField(configurationHandler: handler)
        showAlertController(alertCtrl, actions: actions)
    }
    
    private func showAlertController(_ alertCtrl: UIAlertController, actions: [UIAlertAction]? = nil) {
        actions?.forEach({ (alertAction) in
            alertCtrl.addAction(alertAction)
        })
        present(alertCtrl, animated: true, completion: nil)
    }
    
}
