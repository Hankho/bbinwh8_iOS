//
//  AppViewModel.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/16.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import Sodium
import RxSwift
import RxCocoa

class AppViewModel: BaseViewModel {
    
    private let repository = AppRepository.shared
    
    // Rx subjects
    let onGetFATicket = PublishRelay<String?>() // C1
    let onGetSiteInfo = PublishRelay<SiteInfoResponse>() // S1
    var onGetSessionStatus = PublishRelay<Bool>() // S2
    let onGetUserTicket = PublishRelay<String>() // S3
    let onErrorMessage = PublishRelay<APIError>()
    let onError = PublishRelay<Error>()
    
    // Variables
    private(set) var siteInfo: SiteInfoResponse?
    private(set) var userId: String?
    private(set) var token: String?
    var isUserLoggedIn: Bool {
        get {
            return userId != nil
        }
    }
    var isBiometricEnabled: Bool {
        get {
            return repository.loadAccountsFromKeychain()?.contains(where: { $0.key == userId }) ?? false
        }
    }
    var appVersion: String {
        get {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        }
    }
    
}

// MARK: - Account Controls
extension AppViewModel {
    
    func loadAccounts() -> [String: String]? {
        return repository.loadAccountsFromKeychain()
    }
    
    func tokenForAccount(_ userId: String) -> String? {
        return loadAccounts()?[userId]
    }
    
    func storeAccount(userId: String, token: String) {
        repository.storeAccountToKeychain(userId: userId, token: token)
    }
    
    func removeAccount(_ account: String?) {
        if let account = account {
            repository.removeAccountFromKeychain(userId: account)
        } else {
            // TODO: - Error handling
            onError.accept(NSError())
        }
    }
    
    func removeCurrentAccount() {
        removeAccount(userId)
    }
    
    func clearCookies(domain: String?) {
        guard let domain = domain, let homeUrl = URL(string: domain), let host = homeUrl.host else {
            // TODO: - Error handling
            onError.accept(NSError())
            return
        }
        repository.clearCookies(domain: host)
    }
    
}

// MARK: - API Requests
extension AppViewModel {
    
    // C1
    func requestUserSessionToken() {
        guard let homeAddress = siteInfo?.homeAddress, let homeUrl = URL(string: homeAddress), let host = homeUrl.host else {
            // TODO: - Error handling
            onError.accept(NSError())
            return
        }
        // Get token from cookie["faticket"]
        repository.getFATicket(domain: host).subscribe(
            onSuccess: { [weak self] (cookie) in
                let faTicket = cookie?.value
                self?.token = faTicket
                self?.onGetFATicket.accept(faTicket)
            },
            onError: { [weak self] (error) in
                self?.onError.accept(error)
        }).disposed(by: disposeBag)
    }
    
    // S1
    func requestSiteInfo() {
        repository.requestSiteInfo().subscribe(
            onSuccess: { [weak self] (response) in
                self?.siteInfo = response
                self?.clearCookies(domain: response.homeAddress)
                self?.onGetSiteInfo.accept(response)
            },
            onError: { [weak self] (error) in
                self?.onError.accept(error)
        }).disposed(by: disposeBag)
    }
    
    // S2
    func requestSessionStatus(token: String) {
        guard let homeAddress = siteInfo?.homeAddress else {
            // TODO: - Error handling
            onError.accept(NSError())
            return
        }
        repository.requestSessionStatus(homeAddress, token).subscribe(
            onSuccess: { [weak self] (response) in
                let userId = response.userId
                self?.userId = userId
                // User is logged in if the returned userId in response is not nil
                self?.onGetSessionStatus.accept(userId != nil)
            },
            onError: { [weak self] (error) in
                self?.onError.accept(error)
        }).disposed(by: disposeBag)
    }
    
    // S3
    func requestUserTicket(userId: String, token: String) {
        guard let homeAddress = siteInfo?.homeAddress else {
            // TODO: - Error handling
            onError.accept(NSError())
            return
        }
        repository.requestUserTicket(homeAddress, userId, token).subscribe(
            onSuccess: { [weak self] (response) in
                if response.code == 0, let userTicket = response.userTicket {
                    self?.storeAccount(userId: userId, token: userTicket)
                    self?.onGetUserTicket.accept(userTicket)
                } else if let message = response.message {
                    let error = APIError(reason: message, description: NSLocalizedString("delete.binding.user", comment: ""), userInfo: userId)
                    self?.onErrorMessage.accept(error)
                }
            },
            onError: { [weak self] (error) in
                self?.onError.accept(error)
        }).disposed(by: disposeBag)
    }
    
}
