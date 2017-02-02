//
//  ExtensionsViewControllerTableViewController.swift
//  RadiumBrowser
//
//  Created by bslayter on 2/2/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

class ExtensionsTableViewController: UITableViewController {

	var extensions: Results<ExtensionModel>?
    
    var notificationToken: NotificationToken!
    var realm: Realm!
	
	deinit {
		notificationToken.stop()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Extensions"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.done(sender:)))
        
        do {
            self.realm = try Realm()
			self.notificationToken = realm.addNotificationBlock { notification, realm in
				DispatchQueue.main.async {
					self.tableView.reloadSections([1], with: .automatic)
				}
			}
            self.extensions = realm.objects(ExtensionModel.self)
        } catch let error as NSError {
            print("Error occured opening realm: \(error.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func done(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		if indexPath.section == 1 {
			return true
		}
		
		return false
	}
	
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return extensions?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = "Add new extension"
        } else {
			if let item = extensions?[indexPath.row] {
				cell.textLabel?.text = item.name
			}
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
			do {
				try realm.write {
					let id = UUID().uuidString
					realm.add(ExtensionModel(value: ["source": "document.body.style.background = \"#777\";", "name": "Background Red", "id": id]))
				}
			} catch {
				print("Could not write extension")
			}
            self.tableView.reloadSections([1], with: .automatic)
        }
    }
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		guard let _ = extensions else { return }
		guard let _ = realm else { return }
		
		do {
			try realm.write {
				realm.delete(extensions![indexPath.row])
			}
		} catch let error as NSError {
			print("Could not delete object: \(error.localizedDescription)")
		}
	}

}
