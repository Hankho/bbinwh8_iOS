//
//  AppRepository.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Moya
import WebKit
import RxSwift
import KeychainAccess

class AppRepository {
    
    static let shared = AppRepository()
    private let apiManager = APIManager.shared
    private let keychain = Keychain()
    
}

// MARK: - Account Controls
extension AppRepository {
    
    func storeAccountToKeychain(userId: String, token: String) {
        // Update account list
        var accounts = loadAccountsFromKeychain() ?? [:]
        accounts[userId] = token
        let data = accounts.toData()
        // Store to keychain
        do {
            try keychain.set(data, key: Key.userAccounts)
        } catch let error {
            print("storeAccountInKeychain error: \(error)")
        }
    }
    
    func removeAccountFromKeychain(userId: String) {
        // Remove account from list
        let accounts = loadAccountsFromKeychain()?.filter { $0.key != userId }
        // Store the updated account list back to keychain
        if let data = accounts?.toData() {
            do {
                try keychain.set(data, key: Key.userAccounts)
            } catch let error {
                print("removeAccountFromKeychain error: \(error)")
            }
        }
    }
    
    func clearCookies(domain: String) {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
            cookies.forEach { (cookie) in
                if cookie.domain == domain {
                    WKWebsiteDataStore.default().httpCookieStore.delete(cookie)
                }
            }
        }
        HTTPCookieStorage.shared.cookies?.forEach { (cookie) in
            if cookie.domain == domain {
                HTTPCookieStorage.shared.deleteCookie(cookie)
            }
        }
    }
    
    // MARK: - Deprecated, use Keychain to store accounts instead
    
    func loadAccounts() -> [String: String]? {
        if let accounts = UserDefaults.standard.value(forKey: Key.userAccounts) as? [String: String] {
            return accounts.mapValues { (value) -> String in
                return value.decrypt()
            }
        }
        return nil
    }
    
    func storeAccount(userId: String, token: String) {
        if var accounts = loadAccounts() {
            accounts[userId] = token
            let accountsEncrypted = accounts.mapValues { (value) -> String in
                return value.encrypt()
            }
            UserDefaults.standard.set(accountsEncrypted, forKey: Key.userAccounts)
        } else {
            UserDefaults.standard.set([userId: token.encrypt()], forKey: Key.userAccounts)
        }
    }
    
    func removeAccount(userId: String) {
        if var accounts = loadAccounts() {
            accounts = accounts.filter { $0.key != userId }
            UserDefaults.standard.set(accounts, forKey: Key.userAccounts)
        }
    }
    
    func loadAccountsFromKeychain() -> [String: String]? {
        var data: Data?
        do {
            // Load accounts from keychain
            data = try keychain.getData(Key.userAccounts)
        } catch let error {
            print("loadAccountsFromKeychain error: \(error)")
        }
        return data?.toDictionary()
    }
    
}

// MARK: - API Requests
extension AppRepository {
    
    // C1 @usertoken=cookie["faticket"]
    func getFATicket(domain: String) -> Single<HTTPCookie?> {
        return Single.create { (single) in
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { (cookies) in
                // Get FATicket
                let faTicket = cookies.first(where: { (cookie) -> Bool in
                    cookie.domain == domain && cookie.name == "faticket"
                })
                single(.success(faTicket))
            }
            return Disposables.create()
        }
    }
    
    // S1
    func requestSiteInfo() -> Single<SiteInfoResponse> {
        return apiManager
            .fetchData(service: .GetSiteInfo(AppUtil.targetId))
            .map(SiteInfoResponse.self)
    }
    
    // S2
    func requestSessionStatus(_ homeAddress: String, _ token: String) -> Single<SessionStatusResponse> {
        return apiManager
            .fetchData(service: .GetSessionStatus(homeAddress, token))
            .map(SessionStatusResponse.self)
    }
    
    // S3
    func requestUserTicket(_ homeAddress: String, _ userId: String, _ token: String) -> Single<UserTicketResponse> {
        return apiManager
            .fetchData(service: .GetUserTicket(homeAddress, userId, token))
            .map(UserTicketResponse.self)
    }
    
}
