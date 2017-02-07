//
//  HistoryTableViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/6/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryTableViewController: UITableViewController {

	var notificationToken: NotificationToken!
	var realm: Realm!
	
	var history: Results<HistoryEntry>?
	
	deinit {
		notificationToken.stop()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "History"

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
		
		do {
			realm = try Realm()
			notificationToken = realm.addNotificationBlock { notification, realm in
				DispatchQueue.main.async {
					self.tableView.reloadSections([0], with: .automatic)
				}
			}
			history = realm.objects(HistoryEntry.self)
		} catch let error {
			logRealmError(error: error)
		}
		
		self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func done() {
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
		cell?.textLabel?.text = entry?.pageTitle
		cell?.detailTextLabel?.text = entry?.pageURL

        return cell!
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
			}
		} catch let error as NSError {
			print("Could not delete object: \(error.localizedDescription)")
		}
    }

}
