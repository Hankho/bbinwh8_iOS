//
//  SettingsViewController.swift
//  tetrapods-ios
//
//  Created by Gary Lin on 2019/7/15.
//  Copyright © 2019 Gary Lin. All rights reserved.
//

import RxCocoa

// MARK: - New Instance
extension SettingsViewController {
    
    static func newInstance(viewModel: AppViewModel) -> SettingsViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        vc.setup(viewModel: viewModel)
        return vc
    }
    
    private func setup(viewModel: AppViewModel) {
        self.viewModel = viewModel
    }
    
}

enum SettingsItem: Int, CaseIterable {
    case account
    case biometric
    
    var header: String? {
        switch self {
        case .account: return NSLocalizedString("account", comment: "")
        case .biometric: return nil
        }
    }
    
    var rows: [String] {
        switch self {
        case .account: return [NSLocalizedString("bound.account", comment: ""), NSLocalizedString("current.user", comment: "")]
        case .biometric: return [NSLocalizedString("setting.login.security", comment: "")]
        }
    }
    
    var footer: String? {
        switch self {
        case .account: return nil
        case .biometric: return NSLocalizedString("setting.login.footer", comment: "")
        }
    }
}

class SettingsViewController: BaseViewController {
    
    // Views
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var requireLoginView: UIView!
    
    // View model
    private var viewModel: AppViewModel!
    
    // Rx subjects
    let onIndicatorStateChanged = PublishRelay<Bool>()
    let onBiometricLoginStateChanged = PublishRelay<Bool>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeAndSubscribe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set view
        updateUI(isLoggedIn: viewModel.isUserLoggedIn)
        
        // F3 Start, check status if not yet logged in
        onIndicatorStateChanged.accept(true)
        viewModel.requestUserSessionToken() // C1
    }
    
    private func observeAndSubscribe() {
        // Observe C1 response
        viewModel.onGetFATicket.subscribe(onNext: { [weak self] (faTicket) in
            if let faTicket = faTicket {
                self?.viewModel.requestSessionStatus(token: faTicket) // S2
            } else {
                self?.onIndicatorStateChanged.accept(false)
                self?.updateUI(isLoggedIn: false)
            }
        }).disposed(by: disposeBag)
        
        // Observe S2 response
        viewModel.onGetSessionStatus.subscribe(onNext: { [weak self] (loggedIn) in
            self?.updateUI(isLoggedIn: loggedIn)
            self?.onIndicatorStateChanged.accept(false)
        }).disposed(by: disposeBag)
    }
    
    private func updateUI(isLoggedIn: Bool) {
        // Reload table view
        reloadTableView()
        // Show/hide view
        tableView.isHidden = !isLoggedIn
        requireLoginView.isHidden = isLoggedIn
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }

}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsItem.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let item = SettingsItem(rawValue: section)!
        switch item {
        case .account:
            return 0 // Disabled
        default:
            return item.rows.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0 // Disabled
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderFooterCell")
        
        let item = SettingsItem(rawValue: section)!
        switch item {
        case .account:
            return nil // Disabled
        default:
            let header = cell?.viewWithTag(101) as? UILabel
            header?.text = item.header
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let item = SettingsItem(rawValue: section)!
        switch item {
        case .account:
            return 0 // Disabled
        default:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderFooterCell")
        
        let item = SettingsItem(rawValue: section)!
        switch item {
        case .account:
            return nil // Disabled
        default:
            let footer = cell?.viewWithTag(101) as? UILabel
            footer?.text = item.footer
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = SettingsItem(rawValue: indexPath.section)!
        switch item {
        case .account:
            return setValueCell(item, at: indexPath)
        case .biometric:
            return setSwitchCell(item, at: indexPath)
        }
    }
    
    private func setValueCell(_ item: SettingsItem, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ValueCell", for: indexPath)
        return cell
    }
    
    private func setSwitchCell(_ item: SettingsItem, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath)
        
        let titleLabel = cell.viewWithTag(101) as! UILabel
        titleLabel.text = item.rows[indexPath.row]
        
        let biometricSwitch = cell.viewWithTag(102) as! UISwitch
        biometricSwitch.setOn(viewModel.isBiometricEnabled, animated: false)
        biometricSwitch.addTarget(self, action: #selector(onBiometricSwitchStateChanged), for: .valueChanged)
        
        return cell
    }
    
    @objc
    private func onBiometricSwitchStateChanged(sender: UISwitch) {
        onBiometricLoginStateChanged.accept(sender.isOn)
    }
    
}
