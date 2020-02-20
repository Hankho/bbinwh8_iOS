//
//  SharedWebViewController.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import WebKit
import RxCocoa

// MARK: - New Instance
extension SharedWebViewController {
    
    static func newInstance(viewModel: AppViewModel) -> SharedWebViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SharedWeb") as! SharedWebViewController
        vc.setup(viewModel: viewModel)
        return vc
    }
    
    private func setup(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }
    
}

class SharedWebViewController: BaseViewController {
    
    // Views
    private let wkWebView = WKWebView()
    
    // View model
    private var viewModel: AppViewModel?
    
    // Rx subjects
    let onIndicatorStateChanged = PublishRelay<Bool>()
    let onBackNavigationStateChanged = PublishRelay<Bool>()
    let onLoadingNavigationUrl = PublishRelay<String?>()
    
    // Constants
    private let allowedSchemes = ["ds41cm", "itms-services", "line", "itms-apps", "weixin", "alipays"]
    // Intend to deal with landscape problem for these domains
    private let exceptionDomains = ["static-as-edged.hep200512.com"]
    // Variables
    private var newNavi: WKNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        // Observer keyboard hidding notification
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Check if the device is turning landscape, and only reload if it is not in the home domain
        if UIDevice.current.orientation.isLandscape {
            if let homeAddress = viewModel?.siteInfo?.homeAddress,
                let isHomeDomain = wkWebView.url?.absoluteString.hasPrefix(homeAddress),
                !isHomeDomain {
                if let domain = wkWebView.url?.host, exceptionDomains.contains(domain){
                    wkWebView.reload()
                }
            }
        }
    }
    
    // Reset WKWebView content offset when keyboard hides
    @objc func onKeyboardWillHide() {
        wkWebView.scrollView.setContentOffset(.zero, animated: true)
    }
    
    private func setupWebView() {
        // Disable bounces on the scroll view
        wkWebView.scrollView.bounces = false
        
        // Ignore safe area inset for the webView
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        
        // https://stackoverflow.com/questions/47309048/enable-cross-site-tracking-in-wkwebview
        // A private function to fix the issue that third party cookie gets blocked by WKWebView
        wkWebView.configuration.processPool.perform(Selector("_setCookieAcceptPolicy:"), with: HTTPCookie.AcceptPolicy.always)
        
        // Set WKWebView delegate
        wkWebView.uiDelegate = self
        wkWebView.navigationDelegate = self
        
        // Set WKWebView constraints
        view.addSubview(wkWebView)
        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        wkWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        wkWebView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        wkWebView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        // Set WKWebView user agent
        wkWebView.evaluateJavaScript("navigator.userAgent") { [weak self] (result, error) in
            if let userAgent = result {
                self?.wkWebView.customUserAgent = "\(userAgent) iOSApp"
            }
        }
    }
    
    func loadUrl(_ urlString: String) {
        // Manually add '/' at the end to make the full url path consistent
        let url = URL(string: urlString)!.appendingPathComponent("")
        
        // Avoid loading the same url
        if url == wkWebView.url {
            // Set back button state
            onBackNavigationStateChanged.accept(wkWebView.canGoBack)
        } else {
            let request = URLRequest(url: url)
            newNavi = wkWebView.load(request)
        }
    }
    
    func reload() {
        wkWebView.reload()
    }
    
    func goBack() {
        wkWebView.goBack()
    }
    
    // S4
    func userTicketLogin(userTicket: String) {
        if let homeAddress = viewModel?.siteInfo?.homeAddress {
            loadUrl("\(homeAddress)/WebAPI/UserTicketLogin?UserTicket=\(userTicket)")
        }
    }
    
}

// MARK: - WKUIDelegate
extension SharedWebViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        webView.load(navigationAction.request)
        return nil
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let okBtn = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { (_) in
            completionHandler()
        }
        showAlert(message: message, actions: [okBtn])
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let okBtn = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { (_) in
            completionHandler(true)
        }
        let cancelBtn = UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel) { (_) in
            completionHandler(false)
        }
        showAlert(message: message, actions: [okBtn, cancelBtn])
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        var input: UITextField?
        let okBtn = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default) { (_) in
            completionHandler(input?.text)
        }
        showInputAlert(title: prompt, message: defaultText, actions: [okBtn]) { (textField) in
            input = textField
        }
    }
    
}

// MARK: - WKNavigationDelegate
extension SharedWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // On receving a new navigation action
        let navigationUrl = navigationAction.request.url?.absoluteString
        onLoadingNavigationUrl.accept(navigationUrl)
        // Allow all navigation
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Show loading indicator on navigation start
        onIndicatorStateChanged.accept(true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Set back button state
        onBackNavigationStateChanged.accept(webView.canGoBack)
        
        // Stop loading indicator on finished loading
        onIndicatorStateChanged.accept(false)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        // URL scheme has to be handled manually in WKWebView
        handleURLScheme(error)
        
        // Stop loading indicator on finished loading
        onIndicatorStateChanged.accept(false)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // URL scheme has to be handled manually in WKWebView
        handleURLScheme(error)
        
        // Stop loading indicator on finished loading
        onIndicatorStateChanged.accept(false)
    }
    
    private func handleURLScheme(_ error: Error) {
        // Get the failed url streing from userInfo
        if let failingUrlString = (error as NSError).userInfo["NSErrorFailingURLStringKey"] as? String {
            // Check url scheme and if it is allowed in this app
            if let url = URL(string: failingUrlString),
                let scheme = url.scheme, allowedSchemes.contains(scheme) {
                // Open the url scheme
                UIApplication.shared.open(url) { [weak self] (success) in
                    // Show an alert if failed to open the url scheme
                    if !success {
                        let okBtn = UIAlertAction(title: NSLocalizedString("confirm", comment: ""), style: .default)
                        self?.showAlert(message: NSLocalizedString("handle.urlscheme", comment: ""), actions: [okBtn])
                    }
                }
            }
        }
    }
    
}
