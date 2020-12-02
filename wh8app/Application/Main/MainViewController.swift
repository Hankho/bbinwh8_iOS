//
//  MainViewController.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import UIKit
import RxCocoa
import LocalAuthentication

class MainViewController: BaseViewController {
    
    // Views
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var noticeBubble: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // Constraints
    @IBOutlet weak var botNavBarHeight: NSLayoutConstraint!
    @IBOutlet weak var botNavBarOffset: NSLayoutConstraint!
    @IBOutlet weak var botNavBarTrailing: NSLayoutConstraint!
    @IBOutlet weak var botNavBarTop: NSLayoutConstraint!
    
    // Bottom controls
    @IBOutlet weak var bottomControls: UIView!
    @IBOutlet weak var bottomBtns: UIStackView!
    
    // Control buttons
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet var controlButtons: [UIButton]!
    
    // Tab buttons
    @IBOutlet weak var homeBtn: UIButton!
    @IBOutlet weak var chatBtn: UIButton!
    @IBOutlet weak var settingsBtn: UIButton!
    @IBOutlet var tabButtons: [UIButton]!
    
    // View controllers
    lazy var sharedWebVC = { SharedWebViewController.newInstance(viewModel: viewModel) }()
    lazy var settingsVC = { SettingsViewController.newInstance(viewModel: viewModel) }()
    private var selectedVC: UIViewController?
    

    // View model
    private let viewModel = AppViewModel()
    
    // Rx subjects
    let onListenApiCalling = PublishRelay<Bool>()
    let onListenＷebLoading = PublishRelay<Bool>()
    
    // LaunchImage for listening api calling...
    var CallApiImg: UIImageView = {
        let image = UIImage(named: "apicalling_image.png")
        let imageView = UIImageView(image: image!)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        imageView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        return imageView
    }()
    
    // BlockImage for listening Webview loading...
    var WebLoadImg: UIImageView = {
        let image = UIImage(named: "webviewloading_image.png")
        let imageView = UIImageView(image: image!)
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        imageView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        imageView.autoresizingMask =  [.flexibleWidth, .flexibleHeight]
        return imageView
    }()
    
    // Variables
    private var laContext = LAContext()
    private lazy var biometryType: BiometryType = {
        laContext.biometryType == LABiometryType.faceID ? BiometryType.faceId : BiometryType.touchId
    }()
    private var biometricAuthReason: String?
    private var biometricAuthPolicy: LAPolicy?
    private var onBiometricAuthSuccess: (() -> Void)?
    private var onBiometricAuthCancel: (() -> Void)?
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        get {
            return UIDevice.current.orientation.isLandscape
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialisation()
        observeAndSubscribe()
        onListenＷebLoading.accept(true)
        onListenApiCalling.accept(true)
        requestSiteInfo() // S1
        
        // Hide the bottom navigation view in landscape mode
        let bottomOffset = botNavBarHeight.constant + view.safeAreaInsets.bottom
        botNavBarTop.constant = UIApplication.shared.statusBarOrientation.isLandscape ? bottomOffset : 0
        
        // Offset the bottom navigation view trailing in landscape mode
        let bottomTailingOffset = botNavBarHeight.constant
        botNavBarTrailing.constant = UIApplication.shared.statusBarOrientation.isLandscape ? bottomTailingOffset : 0
        
        if (UIApplication.shared.statusBarOrientation.isLandscape){
            bottomControls.backgroundColor = .green
            let LandscapeWidth = self.view.frame.width
            let LandscapeHeight = self.view.frame.height
            //bottomBtns.axis = .vertical
            UIView.animate(withDuration: 0.5, animations:({
                self.bottomControls.transform = self.bottomControls.transform
                    .rotated(by: CGFloat(Double.pi/2))
                    .translatedBy(x: 0-LandscapeHeight/2+self.botNavBarHeight.constant/2, y: 0-LandscapeWidth/2+self.botNavBarHeight.constant/2)
                    .scaledBy(x: LandscapeHeight/LandscapeWidth, y: 1)
                
                self.backBtn.transform = self.backBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.refreshBtn.transform = self.refreshBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.homeBtn.transform = self.homeBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.chatBtn.transform = self.chatBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.settingsBtn.transform = self.settingsBtn.transform.rotated(by: CGFloat(-Double.pi/2))
            }))
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Hide the bottom navigation view in landscape mode
        let bottomOffset = botNavBarHeight.constant + view.safeAreaInsets.bottom
        botNavBarTop.constant = UIDevice.current.orientation.isLandscape ? bottomOffset : 0
        
        // Offset the bottom navigation view trailing in landscape mode
        let bottomTailingOffset = botNavBarHeight.constant
        botNavBarTrailing.constant = UIDevice.current.orientation.isLandscape ? bottomTailingOffset : 0
        
        if (UIDevice.current.orientation.isLandscape){
            bottomControls.backgroundColor = .green
            let LandscapeWidth = self.view.frame.width
            let LandscapeHeight = self.view.frame.height
            //bottomBtns.axis = .vertical
            UIView.animate(withDuration: 0.5, animations:({
                self.bottomControls.transform = self.bottomControls.transform
                    .rotated(by: CGFloat(Double.pi/2))
                    .translatedBy(x: 0-LandscapeWidth/2+self.botNavBarHeight.constant/2, y: 0-LandscapeHeight/2+self.botNavBarHeight.constant/2)
                    .scaledBy(x: LandscapeWidth/LandscapeHeight, y: 1)
                
                self.backBtn.transform = self.backBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.refreshBtn.transform = self.refreshBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.homeBtn.transform = self.homeBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.chatBtn.transform = self.chatBtn.transform.rotated(by: CGFloat(-Double.pi/2))
                self.settingsBtn.transform = self.settingsBtn.transform.rotated(by: CGFloat(-Double.pi/2))
            }))
        }
        else{
            bottomControls.backgroundColor = .cyan
            let PortraitWidth = self.view.frame.width
            let PortraitHeight = self.view.frame.height
            //bottomBtns.axis = .horizontal
            UIView.animate(withDuration: 0.5, animations:({
                self.bottomControls.transform = self.bottomControls.transform
                    .scaledBy(x: PortraitWidth/PortraitHeight, y: 1)
                    .translatedBy(x: 0+PortraitHeight/2-self.botNavBarHeight.constant/2, y: 0+PortraitWidth/2-self.botNavBarHeight.constant/2)
                    .rotated(by: CGFloat(-Double.pi/2))
                
                self.backBtn.transform = self.backBtn.transform.rotated(by: CGFloat(Double.pi/2))
                self.refreshBtn.transform = self.refreshBtn.transform.rotated(by: CGFloat(Double.pi/2))
                self.homeBtn.transform = self.homeBtn.transform.rotated(by: CGFloat(Double.pi/2))
                self.chatBtn.transform = self.chatBtn.transform.rotated(by: CGFloat(Double.pi/2))
                self.settingsBtn.transform = self.settingsBtn.transform.rotated(by: CGFloat(Double.pi/2))
            }))
        }
    }
    
    private func initialisation() {
        // Set tap gesture for the bubble view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideBubbleAction))
        noticeBubble.addGestureRecognizer(tapGesture)
    }
    
    private func observeAndSubscribe() {
        // Observe S1 response
        viewModel.onGetSiteInfo.subscribe(onNext: { [weak self] (siteInfo) in
            // Check for new app version and avoid any interaction if an update is required
            if let appVersion = self?.viewModel.appVersion {
                if Double(appVersion)! < siteInfo.apiVersion {
                    self?.showUpdateDialog(urlString: siteInfo.downloadPath) // F1
                } else {
                    self?.goHomePage(urlString: siteInfo.homeAddress) // F2
                    self?.checkLocalAccounts() // F5
                }
                //self?.CallApiImg.removeFromSuperview()
                self?.onListenApiCalling.accept(false)
            }
            
            // Stop loading indicator
            self?.showActivityIndicator(false)
        }).disposed(by: disposeBag)
        
        // Observe S3 response - success
        viewModel.onGetUserTicket.subscribe(onNext: { [weak self] (userTicket) in
            // User login via the webview
            self?.sharedWebVC.userTicketLogin(userTicket: userTicket) // S4
            // Hide notice bubble on user ticket get
            self?.showNoticeBubble(false)
        }).disposed(by: disposeBag)
        
        // Observe S3 response - error
        viewModel.onErrorMessage.subscribe(onNext: { [weak self] (error) in
            // Show error alert which allows the use to remove account
            let userId = error.userInfo as? String
            let okBtn = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { (_) in
                self?.viewModel.removeAccount(userId)
            }
            let cancelBtn = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel)
            self?.showAlert(title: error.reason, message: error.description, actions: [okBtn, cancelBtn])
            // Stop loading indicator
            self?.showActivityIndicator(false)
        }).disposed(by: disposeBag)
        
        // Observe api calling state in MainViewController
        self.onListenApiCalling.subscribe(onNext: { [weak self] (show) in
            // Show or Hide CallApiImage
            self?.showCallApiImage(show)
        }).disposed(by: disposeBag)
        
        // Observe webview loading state in MainViewController
        self.onListenＷebLoading.subscribe(onNext: { [weak self] (show) in
            // Show or Hide WebLoadImage
            self?.showWebLoadImage(show)
        }).disposed(by: disposeBag)
        
        // Observe webview loading state in SharedWebViewController
        sharedWebVC.onListenＷebLoading.subscribe(onNext: { [weak self] (show) in
            // Show or Hide WebLoadImage
            self?.showWebLoadImage(show)
        }).disposed(by: disposeBag)
        
        // Observe activity indicator state change in SharedWebViewController
        sharedWebVC.onIndicatorStateChanged.subscribe(onNext: { [weak self] (show) in
            // Start or stop loading indicator
            self?.showActivityIndicator(show)
        }).disposed(by: disposeBag)
        
        // Observe back navigation state change in SharedWebViewController
        sharedWebVC.onBackNavigationStateChanged.subscribe(onNext: { [weak self] (enable) in
            self?.enableBackNavigation(enable)
        }).disposed(by: disposeBag)
        
        // Observe any navigation action in SharedWebViewController
        sharedWebVC.onLoadingNavigationUrl.subscribe(onNext: { [weak self] (navigationUrl) in
            // Check and display local accounts
            if let loginAddress = self?.viewModel.siteInfo?.loginAddress, navigationUrl == loginAddress {
                self?.checkLocalAccounts() // F5
            }
        }).disposed(by: disposeBag)
        
        // Observe activity indicator state change in SettingsViewController
        settingsVC.onIndicatorStateChanged.subscribe(onNext: { [weak self] (show) in
            // Start or stop loading indicator
            self?.showActivityIndicator(show)
        }).disposed(by: disposeBag)
        
        // Observe biometric login state change in SettingsViewController
        settingsVC.onBiometricLoginStateChanged.subscribe(onNext: { [weak self] (enable) in
            if enable {
                // F4 - On enabling biometric login, start biometric authentication
                self?.biometricAuthentication(
                    reason: NSLocalizedString("verify.enable.login.security", comment: ""),
                    onSuccess: { [weak self] in
                        // Add account to the local UserDefaults on authenticated
                        if let userId = self?.viewModel.userId, let token = self?.viewModel.token {
                            self?.viewModel.storeAccount(userId: userId, token: token)
                        }
                        // Hide notice bubble on bio auth enabled
                        self?.showNoticeBubble(false)
                    },
                    onCancel: { [weak self] in
                        self?.settingsVC.reloadTableView()
                })
            } else {
                // F4 - On disabling biometric login, remove account from the local UserDefaults
                self?.biometricAuthentication(
                    reason: NSLocalizedString("verify.disable.login.security", comment: ""),
                    onSuccess: { [weak self] in
                        // Add account to the local UserDefaults on authenticated
                        self?.viewModel.removeCurrentAccount()
                    },
                    onCancel: { [weak self] in
                        self?.settingsVC.reloadTableView()
                })
            }
        }).disposed(by: disposeBag)
    }
    
    private func requestSiteInfo() {
        // Start loading indicator
        showActivityIndicator(true)
        // Send request
        viewModel.requestSiteInfo() // S1
    }
    
    private func requestUserTicket(userId: String, token: String) {
        // Start loading indicator
        showActivityIndicator(true)
        // Send request
        viewModel.requestUserTicket(userId: userId, token: token) // S3
    }

    private func showActivityIndicator(_ show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func showCallApiImage(_ show: Bool) {
        if show {
            self.view.addSubview(CallApiImg)
        } else {
            self.CallApiImg.removeFromSuperview()
        }
    }
    
    private func showWebLoadImage(_ show: Bool) {
        if show {
            self.view.addSubview(WebLoadImg)
        } else {
            self.WebLoadImg.removeFromSuperview()
        }
    }
    
    private func enableBackNavigation(_ enable: Bool) {
        backBtn.isEnabled = enable
    }
    
    private func showNoticeBubble(_ show: Bool) {
        if show {
            noticeBubble.fadeIn(duration: Interval.animationShort)
        } else {
            noticeBubble.fadeOut(duration: Interval.animationShort)
        }
    }
    
    @objc func hideBubbleAction(_ sender : UITapGestureRecognizer) {
        showNoticeBubble(false)
    }
    
    // F1
    private func showUpdateDialog(urlString: String) {
        let goBtn = UIAlertAction(title: NSLocalizedString("update", comment: ""), style: .default) { [weak self] (_) in
            if let downloadUrl = URL(string: urlString), UIApplication.shared.canOpenURL(downloadUrl) {
                UIApplication.shared.open(downloadUrl)
            }
            self?.showAlert(message: NSLocalizedString("update.restart", comment: ""))
        }
        showAlert(message: NSLocalizedString("update.new.version", comment: ""), actions: [goBtn])
    }
    
    // F2
    private func goHomePage(urlString: String) {
        goSharedWebView(urlString: urlString, homeBtn)
    }
    
    private func goSharedWebView(urlString: String, _ sender: UIButton) {
        navigate(to: sharedWebVC, hasControl: true)
        sharedWebVC.loadUrl(urlString)
        sender.isSelected = true
    }
    
    // F5
    private func checkLocalAccounts() {
        if let accounts = viewModel.loadAccounts(), !accounts.isEmpty {
            biometricAuthentication(
                reason: NSLocalizedString("verify.autologin", comment: ""),
                onSuccess: { [weak self] in
                    if accounts.count == 1, let account = accounts.first {
                        self?.requestUserTicket(userId: account.key, token: account.value) // S3
                    } else {
                        self?.displayAccountSelection()
                    }
                },
                onCancel: { [weak self] in
                    self?.showCancelConfirmationDialog(
                        onRetry: { [weak self] in
                            self?.biometricAuthentication()
                    })
            })
        } else {
            showNoticeBubble(true)
        }
    }
    
    private func displayAccountSelection() {
        guard let accounts = viewModel.loadAccounts() else { return }
        // Account acount
        var alertActions = [UIAlertAction]()
        for account in accounts.sorted(by: <) {
            let accountBtn = UIAlertAction(title: account.key, style: .default) { [weak self] (button) in
                // Get token from the selected account
                if let userId = button.title, let token = self?.viewModel.tokenForAccount(userId) {
                    self?.requestUserTicket(userId: userId, token: token) // S3
                }
            }
            alertActions.append(accountBtn)
        }
        // Cancel action
        let cancelBtn = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { [weak self] (_) in
            self?.showCancelConfirmationDialog { [weak self] in
                self?.displayAccountSelection()
            }
        }
        alertActions.append(cancelBtn)
        // Display
        showActionSheet(message: NSLocalizedString("select.account", comment: ""), actions: alertActions)
    }
    
    private func navigate(to newVC: UIViewController, hasControl: Bool) {
        // Disable all the tab buttons
        tabButtons.forEach { (button) in
            button.isSelected = false
        }
        // Enable/disable control buttons
        controlButtons.forEach { (button) in
            button.isEnabled = hasControl
        }
        // Go to the new page
        changePage(to: newVC)
    }
    
    // 1. Change to the selected page
    private func changePage(to newVC: UIViewController) {
        // 2. Remove previous page from the container
        selectedVC?.willMove(toParent: nil)
        selectedVC?.view.removeFromSuperview()
        selectedVC?.removeFromParent()
        
        // 3. Add new page to the display container
        addChild(newVC)
        container.addSubview(newVC.view)
        newVC.view.frame = container.bounds
        newVC.didMove(toParent: self)
        
        // 4. New page becomes the currently selected page
        selectedVC = newVC
    }
    
}

// MARK: - Biometric

extension MainViewController {
    enum BiometryType {
        case faceId
        case touchId
        
        var name: String {
            switch self {
            case .faceId:
                return "Face ID"
            case .touchId:
                return "Touch ID"
            }
        }
        
        var title: String {
            switch self {
            case .faceId:
                return NSLocalizedString("face", comment: "")
            case .touchId:
                return NSLocalizedString("fingerprint", comment: "")
            }
        }
    }
    
    func biometricAuthentication(reason: String? = nil, onSuccess: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        if let reason = reason {
            biometricAuthReason = reason
        }
        if let onSuccess = onSuccess {
            onBiometricAuthSuccess = onSuccess
        }
        if let onCancel = onCancel {
            onBiometricAuthCancel = onCancel
        }
        
        guard let reason = biometricAuthReason else { return }
        
        laContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if success {
                    self?.onBiometricAuthSuccess?()
                } else if let error = error {
                    self?.handleErrorCodes(error)
                }
                self?.laContext = LAContext()
            }
        }
    }
    
    private func handleErrorCodes(_ error: Error) {
        // https://developer.apple.com/documentation/localauthentication/laerror/code
        switch (error) {
        // Cancellation
        case LAError.userCancel:
            onBiometricAuthCancel?()
        // Biometry Failure
        case LAError.biometryLockout: // Never called with .deviceOwnerAuthenticationWithBiometrics
            showFailedAndRetryDialog(message: "\(NSLocalizedString("handle.error.fail1", comment: ""))\(biometryType.name)\(NSLocalizedString("handle.error.fail2", comment: ""))")
        case LAError.biometryNotAvailable:
            showBiometricEnrolmentDialog(message: "\(NSLocalizedString("handle.error.enable1", comment: ""))\(biometryType.name)\(NSLocalizedString("handle.error.enable2", comment: ""))\(biometryType.title)\(NSLocalizedString("handle.error.enable3", comment: ""))")
        case LAError.biometryNotEnrolled:
            showBiometricEnrolmentDialog(message: "\(NSLocalizedString("handle.error.enroll1", comment: ""))\(biometryType.name)\(NSLocalizedString("handle.error.enroll2", comment: ""))\(biometryType.title)。")
        // Other Errors
        case LAError.authenticationFailed:
            showFailedAndRetryDialog(message: "\(biometryType.name)\(NSLocalizedString("handle.error.authenticate1", comment: ""))\(biometryType.title)\(NSLocalizedString("handle.error.authenticate2", comment: ""))\(biometryType.title)\(NSLocalizedString("handle.error.authenticate3", comment: ""))")
        case LAError.passcodeNotSet:
            showBiometricEnrolmentDialog(message: "\(NSLocalizedString("handle.error.password1", comment: "")))\(biometryType.name)\(NSLocalizedString("handle.error.password2", comment: ""))")
        default:
            biometricAuthentication()
        }
    }
    
    private func showCancelConfirmationDialog(onRetry: (() -> Void)? = nil) {
        let retryBtn = UIAlertAction(title: NSLocalizedString("retry", comment: ""), style: .default) { (_) in
            onRetry?()
        }
        let cancelBtn = UIAlertAction(title: NSLocalizedString("exit", comment: ""), style: .cancel) { [weak self] (_) in
            self?.showNoticeBubble(true)
        }
        showAlert(message: NSLocalizedString("show.cancel.confirm", comment: ""), actions: [retryBtn, cancelBtn])
    }
    
    private func showFailedAndRetryDialog(message: String) {
        let okBtn = UIAlertAction(title: NSLocalizedString("retry", comment: ""), style: .default) { [weak self] (_) in
            self?.biometricAuthentication()
        }
        let cancelBtn = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { [weak self] (_) in
            self?.showCancelConfirmationDialog { [weak self] in
                self?.biometricAuthentication()
            }
        }
        showAlert(message: message, actions: [okBtn, cancelBtn])
    }
    
    private func showBiometricEnrolmentDialog(message: String) {
        let okBtn = UIAlertAction(title: NSLocalizedString("set", comment: ""), style: .default) { [weak self] (_) in
            UIApplication.shared.open(URL(string: "App-Prefs:")!)
            self?.showFailedAndRetryDialog(message: NSLocalizedString("biomatric.fail.retry", comment: ""))
        }
        let cancelBtn = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { [weak self] (_) in
            self?.showCancelConfirmationDialog { [weak self] in
                self?.biometricAuthentication()
            }
        }
        showAlert(message: message, actions: [okBtn, cancelBtn])
    }
    
}

// MARK: - Button Actions

extension MainViewController {
    
    @IBAction func onBackTouchUp(_ sender: UIButton) {
        sharedWebVC.goBack()
    }
    
    @IBAction func onRefreshTouchUp(_ sender: UIButton) {
        sharedWebVC.reload()
    }
    
    @IBAction func onHomeTouchUp(_ sender: UIButton) {
        if let homeAddress = viewModel.siteInfo?.homeAddress {
            goSharedWebView(urlString: homeAddress, sender)
        }
    }
    
    @IBAction func onChatTouchUp(_ sender: UIButton) {
        if let chatAddress = viewModel.siteInfo?.chatAddress {
            goSharedWebView(urlString: chatAddress, sender)
        }
    }
    
    @IBAction func onSettingsTouchUp(_ sender: UIButton) {
        if !(selectedVC is SettingsViewController ) {
            navigate(to: settingsVC, hasControl: false)
            sender.isSelected = true
        }
    }
    
}
