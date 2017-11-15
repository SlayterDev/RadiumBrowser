//
//  HistoryTableViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/6/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

protocol HistoryNavigationDelegate: class {
    func didSelectEntry(with url: URL?)
}

class HistoryTableViewController: UITableViewController {
    
    weak var delegate: HistoryNavigationDelegate?
    
	@objc var notificationToken: NotificationToken!
	var realm: Realm!
	
	var history: Results<HistoryEntry>?
	
	deinit {
		notificationToken.stop()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Answers.logContentView(withName: "View History", contentType: nil, contentId: nil, customAttributes: nil)
		
		title = "History"

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
		
		do {
			realm = try Realm()
            history = realm.objects(HistoryEntry.self).sorted(byKeyPath: "visitDate", ascending: false)
            notificationToken = history?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                guard let tableView = self?.tableView else { return }
                switch changes {
                case .initial:
                    tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.endUpdates()
                case .error(let error):
                    logRealmError(error: error)
                }
			}
		} catch let error {
			logRealmError(error: error)
		}
		
		self.tableView.reloadData()
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellIdentifier = "cell"
		
		var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
		if cell == nil {
			cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
		}

        let entry = history?[indexPath.row]
        if let pageTitle = entry?.pageTitle, pageTitle != "" {
            cell?.textLabel?.text = pageTitle
            
            let attrString = getGrayDate(entry!.visitDate)
            attrString.append(NSAttributedString(string: entry!.pageURL))
            cell?.detailTextLabel?.attributedText = attrString
        } else {
            cell?.textLabel?.text = entry?.pageURL
            cell?.detailTextLabel?.attributedText = getGrayDate(entry!.visitDate, attachDash: false)
        }

        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            self.dismiss(animated: true, completion: nil)
        }
        guard let pageURL = history?[indexPath.row].pageURL else { return }
        
        let url = URL(string: pageURL)
        delegate?.didSelectEntry(with: url)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		guard let _ = history else { return }
		guard let _ = realm else { return }
		
		do {
			try realm.write {
				realm.delete(history!.filter("id = %@", history![indexPath.row].id))
                Answers.logCustomEvent(withName: "Delete History Item", customAttributes: nil)
			}
		} catch let error as NSError {
			print("Could not delete object: \(error.localizedDescription)")
		}
    }
    
    func getGrayDate(_ date: Date, attachDash: Bool = true) -> NSMutableAttributedString {
        let df = DateFormatter()
        df.dateFormat = "MM/dd/yy hh:mma"
        let dateString = df.string(from: date)
        
        return NSMutableAttributedString(string: "\(dateString)\((attachDash) ? " - " : "")", attributes: [.foregroundColor: UIColor.gray])
    }
    
}
