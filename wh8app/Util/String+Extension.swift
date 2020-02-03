//
//  String+Extension.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/18.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Sodium

// MARK: - Deprecated, use Keychain to store accounts instead

extension String {
    
    func encrypt() -> String {
        let sodium = Sodium()
        
        // Find stored secret key string, or create new if not found
        let secretKeyString = UserDefaults.standard.value(forKey: Key.secret) as? String
        let secretKey = secretKeyString == nil ?
            sodium.secretBox.key() : sodium.utils.base642bin(secretKeyString!)!
        if secretKeyString == nil {
            // Store new secret key as string
            UserDefaults.standard.set(sodium.utils.bin2base64(secretKey), forKey: Key.secret)
        }
        
        // Encrypt string
        let message = self.bytes
        let encrypted: Bytes = sodium.secretBox.seal(message: message, secretKey: secretKey)!
        return sodium.utils.bin2base64(encrypted)!
    }
    
    func decrypt() -> String {
        let sodium = Sodium()
        
        // Find stored secret key string
        let secretKeyString = UserDefaults.standard.value(forKey: Key.secret) as! String
        let secretKey = sodium.utils.base642bin(secretKeyString)!
        
        // Decrypt string
        let encrypted = sodium.utils.base642bin(self)!
        let message = sodium.secretBox.open(nonceAndAuthenticatedCipherText: encrypted, secretKey: secretKey)!
        return message.utf8String!
    }
    
}
