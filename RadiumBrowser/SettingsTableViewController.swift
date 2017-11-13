//
//  SettingsTableViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/2/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyStoreKit
import BulletinBoard
import SwiftKeychainWrapper
import WebKit
import Crashlytics

enum OptionsTitles: String {
    case trackHistory = "Track History"
    
    static let allValues: [OptionsTitles] = [.trackHistory]
}

enum AdBlockingTitles: String {
    case purchaseAdBlock = "Purchase Ad Blocking"
    case restorePurchases = "Restore Purchases"
    
    case enableAdBlock = "Enable Ad Block"
    
    static let unpurchasedValues: [AdBlockingTitles] = [.purchaseAdBlock, .restorePurchases]
    static let purchasedValues: [AdBlockingTitles] = [.enableAdBlock]
}

enum DeleteSectionTitles: String {
    case clearHistory = "Clear History"
    case clearCookies = "Clear Local Storage"
    
    static let allValues: [DeleteSectionTitles] = [.clearHistory, .clearCookies]
}

enum LinksTitles: String {
    case supportPage = "Support Page"
    case codeRepository = "Code Repository"
    
    static let allValues: [LinksTitles] = [.supportPage, .codeRepository]
}

class SettingsTableViewController: UITableViewController {
    
    static let identifier = "SettingsIdentifier"
    
    lazy var bulletinManager: BulletinManager = {
        let rootItem = PageBulletinItem(title: "Ad Blocking")
        if !isiPhone5 {
            rootItem.image = #imageLiteral(resourceName: "NoAds")
        }
        
        rootItem.shouldCompactDescriptionText = true
        rootItem.descriptionText = """
        Purchasing ad block will use our list of sources to filter out ads being served to you by websites you visit. In addition to blocking unwanted content, this will speed up your browsing experience as well as make it safer.
        PLEASE NOTE: Because ad sources are constantly changing we can't guaruntee every single ad will be blocked. We will continue to add known sources to the app to block more ads as we become aware of them.
        
        Would you like to purchase Ad Blocking?
        """
        rootItem.actionButtonTitle = "Purchase ($1.99)"
        rootItem.actionHandler = { _ in
            self.makePurchase()
        }
        rootItem.alternativeHandler = { item in
            item.manager?.dismissBulletin()
        }
        rootItem.alternativeButtonTitle = "Not now"
        return BulletinManager(rootItem: rootItem)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: SettingsTableViewController.identifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func done() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func adBlockPurchased() -> Bool {
        return KeychainWrapper.standard.bool(forKey: SettingsKeys.adBlockPurchased) ?? false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if #available(iOS 11.0, *) {
            return 4
        } else {
            return 3
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var counts = [OptionsTitles.allValues.count, DeleteSectionTitles.allValues.count, LinksTitles.allValues.count]
        if #available(iOS 11.0, *) {
            counts.insert((adBlockPurchased()) ? AdBlockingTitles.purchasedValues.count : AdBlockingTitles.unpurchasedValues.count, at: 1)
        }
        
        return counts[section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if #available(iOS 11.0, *) {
            return nil
        } else if section == 2 {
            return "Upgrade to iOS 11 to have the option to block ads on pages you visit!"
        }
        
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.identifier, for: indexPath)
        
        cell.textLabel?.textColor = .black
        
        var section = indexPath.section
        if #available(iOS 11.0, *) {
            // do nothing
        } else if section > 0 {
            section += 1
        }
        
        switch section {
        case 0:
            let option = OptionsTitles.allValues[indexPath.row]
            cell.textLabel?.text = option.rawValue
            cell.selectionStyle = .none
            
            if option == .trackHistory {
                cell.accessoryView = UISwitch().then {
                    $0.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.trackHistory)
                    $0.addTarget(self, action: #selector(trackHistoryChanged(sender:)), for: .valueChanged)
                }
            }
        case 1:
            if adBlockPurchased() {
                let option = AdBlockingTitles.purchasedValues[indexPath.row]
                cell.textLabel?.text = option.rawValue
                cell.selectionStyle = .none
                cell.textLabel?.textAlignment = .left
                
                if option == .enableAdBlock {
                    cell.accessoryView = UISwitch().then {
                        $0.isOn = UserDefaults.standard.bool(forKey: SettingsKeys.adBlockEnabled)
                        $0.addTarget(self, action: #selector(adBlockEnabledChanged(sender:)), for: .valueChanged)
                    }
                }
            } else {
                cell.textLabel?.text = AdBlockingTitles.unpurchasedValues[indexPath.row].rawValue
                cell.selectionStyle = .default
                cell.textLabel?.textAlignment = .center
            }
        case 2:
            cell.selectionStyle = .default
            cell.textLabel?.textColor = .red
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = DeleteSectionTitles.allValues[indexPath.row].rawValue
        case 3:
            cell.selectionStyle = .none
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = LinksTitles.allValues[indexPath.row].rawValue
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var section = indexPath.section
        if #available(iOS 11.0, *) {
            // do nothing
        } else if section > 0 {
            section += 1
        }
        
        switch section {
        case 1:
            if !adBlockPurchased() {
                didSelectAdBlock(withRowIndex: indexPath.row)
            }
        case 2:
            didSelectClearSection(withRowIndex: indexPath.row)
        case 3:
            didSelectLinkSection(withRowIndex: indexPath.row)
        default:
            break
        }
    }
    
    // MARK: - Clear Section
    
    func didSelectClearSection(withRowIndex rowIndex: Int) {
        switch DeleteSectionTitles.allValues[rowIndex] {
        case .clearHistory:
            clearHistory()
        case .clearCookies:
            clearCookies()
        }
    }
    
    func clearHistory() {
        func doTheClear() {
            do {
                let realm = try Realm()
                let historyItems = realm.objects(HistoryEntry.self)
                
                try realm.write {
                    realm.delete(historyItems)
                }
            } catch {
                print("Could not clear history: \(error.localizedDescription)")
            }
        }
        
        let av = UIAlertController(title: "Clear History", message: "Are you sure you want to clear your history?", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            doTheClear()
        }))
        av.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(av, animated: true, completion: nil)
    }
    
    func clearCookies() {
        func doTheClear() {
            let webDataTypes = Set(arrayLiteral: WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeMemoryCache,
                                                  WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage,
                                                  WKWebsiteDataTypeIndexedDBDatabases, WKWebsiteDataTypeWebSQLDatabases)
            WKWebsiteDataStore.default().removeData(ofTypes: webDataTypes, modifiedSince: Date(timeIntervalSince1970: 0), completionHandler: {})
        }
        
        let av = UIAlertController(title: "Clear Local Data", message: "Are you sure you want to clear your cookies?", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            doTheClear()
        }))
        av.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        self.present(av, animated: true, completion: nil)
    }
    
    // MARK: - Settings Functions
    
    @objc func trackHistoryChanged(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: SettingsKeys.trackHistory)
    }
    
    @objc func adBlockEnabledChanged(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: SettingsKeys.adBlockEnabled)
        NotificationCenter.default.post(name: NSNotification.Name.adBlockSettingsChanged, object: nil)
    }
    
    // MARK: - Links Section
    
    func didSelectLinkSection(withRowIndex rowIndex: Int) {
        var urlString = "https://github.com/SlayterDev/RadiumBrowser"
        
        if LinksTitles.allValues[rowIndex] == .supportPage {
            urlString += "/issues"
        }
        
        let request = URLRequest(url: URL(string: urlString)!)
        TabContainerView.currentInstance?.addNewTab(withRequest: request)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - In App Purchase Section
    
    func didSelectAdBlock(withRowIndex rowIndex: Int) {
        if AdBlockingTitles.unpurchasedValues[rowIndex] == .purchaseAdBlock {
            purchaseAdBlock()
        } else {
            restorePurchases()
        }
    }
    
    func makePurchase() {
        bulletinManager.displayActivityIndicator()
        Answers.logStartCheckout(withPrice: 1.99, currency: "USD", itemCount: 1, customAttributes: nil)
        SwiftyStoreKit.purchaseProduct("com.slayterdevelopment.radium.adblocking") { [weak self] result in
            self?.bulletinManager.dismissBulletin()
            switch result {
            case .success(let purchase):
                Answers.logPurchase(withPrice: 1.99, currency: "USD", success: true, itemName: "Ad Block", itemType: "IAP", itemId: nil, customAttributes: nil)
                
                print("Successfully purchased: \(purchase.productId)")
                KeychainWrapper.standard.set(true, forKey: SettingsKeys.adBlockPurchased)
                UserDefaults.standard.set(true, forKey: SettingsKeys.adBlockEnabled)
                NotificationCenter.default.post(name: NSNotification.Name.adBlockSettingsChanged, object: nil)
                
                let av = UIAlertController(title: "Ad Block Purchased!", message: nil, preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                
                DispatchQueue.main.async {
                    self?.present(av, animated: true, completion: nil)
                    self?.tableView.reloadData()
                }
            case .error(let error):
                print("Error purchasing: \(error.localizedDescription)")
            }
        }
    }
    
    func purchaseAdBlock() {
        Answers.logCustomEvent(withName: "Tap purchase", customAttributes: nil)
        bulletinManager.prepare()
        bulletinManager.presentBulletin(above: self)
    }
    
    func restorePurchases() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.center = self.view.center
        spinner.hidesWhenStopped = true
        spinner.color = .gray
        self.tableView.addSubview(spinner)
        spinner.startAnimating()
        
        SwiftyStoreKit.restorePurchases() { [weak self] results in
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            
            if results.restoreFailedPurchases.count > 0 {
                let av = UIAlertController(title: "Restore Failed", message: "Something went wrong restroing purchases. Please try again later.", preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(av, animated: true, completion: nil)
            } else if results.restoredPurchases.count > 0 {
                KeychainWrapper.standard.set(true, forKey: SettingsKeys.adBlockPurchased)
                UserDefaults.standard.set(true, forKey: SettingsKeys.adBlockEnabled)
                NotificationCenter.default.post(name: NSNotification.Name.adBlockSettingsChanged, object: nil)
                
                let av = UIAlertController(title: "Purchases Restored!", message: nil, preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(av, animated: true, completion: nil)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } else {
                let av = UIAlertController(title: "Nothing to Restore", message: nil, preferredStyle: .alert)
                av.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self?.present(av, animated: true, completion: nil)
            }
        }
    }

}
