//
//  SettingsTableViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/2/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

enum OptionsTitles: String {
    case trackHistory = "Track History"
    
    static let allValues: [OptionsTitles] = [.trackHistory]
}

enum DeleteSectionTitles: String {
    case clearHistory = "Clear History"
    case clearCookies = "Clear Cookies"
    
    static let allValues: [DeleteSectionTitles] = [.clearHistory, .clearCookies]
}

enum LinksTitles: String {
    case supportPage = "Support Page"
    case codeRepository = "Code Repository"
    
    static let allValues: [LinksTitles] = [.supportPage, .codeRepository]
}

class SettingsTableViewController: UITableViewController {
    
    static let identifier = "SettingsIdentifier"
    
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return OptionsTitles.allValues.count
        case 1:
            return DeleteSectionTitles.allValues.count
        case 2:
            return LinksTitles.allValues.count
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewController.identifier, for: indexPath)
        
        switch indexPath.section {
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
            cell.selectionStyle = .default
            cell.textLabel?.textColor = .red
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = DeleteSectionTitles.allValues[indexPath.row].rawValue
        case 2:
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
        
        switch indexPath.section {
        case 1:
            didSelectClearSection(withRowIndex: indexPath.row)
        case 2:
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
            if let cookies = HTTPCookieStorage.shared.cookies {
                cookies.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
            }
        }
        
        let av = UIAlertController(title: "Clear Cookies", message: "Are you sure you want to clear your cookies?", preferredStyle: .alert)
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

}
