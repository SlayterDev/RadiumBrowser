//
//  ExtensionsViewControllerTableViewController.swift
//  RadiumBrowser
//
//  Created by bslayter on 2/2/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import Crashlytics

class ExtensionsTableViewController: UITableViewController, ScriptEditorDelegate {

	var extensions: Results<ExtensionModel>?
    
    @objc var notificationToken: NotificationToken!
    var realm: Realm!
	
	deinit {
		notificationToken.stop()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Answers.logContentView(withName: "Extensions", contentType: nil, contentId: nil, customAttributes: nil)
        
        title = "Extensions"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.done(sender:)))
        
        do {
            self.realm = try Realm()
			self.notificationToken = realm.addNotificationBlock { _, _ in
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
    
    @objc func done(sender: UIBarButtonItem) {
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Extensions (tap to edit)"
        }
        
        return ""
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        if indexPath.section == 0 {
            cell.textLabel?.text = "Add new extension..."
        } else {
            cell.accessoryType = .disclosureIndicator
			if let item = extensions?[indexPath.row] {
				cell.textLabel?.text = item.name
                cell.accessoryView = UISwitch().then { [unowned self] in
                    $0.isOn = item.active
                    $0.tag = indexPath.row
                    $0.addTarget(self, action: #selector(self.toggleScript(sender:)), for: .valueChanged)
                }
			}
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
			promptForScriptName()
		} else {
			guard let model = extensions?[indexPath.row] else { return }
			let editor = ScriptEditorViewController()
			editor.delegate = self
			editor.prevModel = model
			editor.scriptName = model.name
			self.navigationController?.pushViewController(editor, animated: true)
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
    
    // MARK: - Actions
	
	@objc func promptForScriptName() {
		let av = UIAlertController(title: "New Extension", message: "Please provide a name for your extension.", preferredStyle: .alert)
        av.addTextField(configurationHandler: { (textField) in
            textField.autocapitalizationType = .words
        })
		av.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
			if let nameText = av.textFields?.first?.text, nameText != "" {
                Answers.logCustomEvent(withName: "Extension Created", customAttributes: ["Script Name": nameText])
				self.presentEditor(name: nameText, source: nil)
			}
		}))
		av.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		self.present(av, animated: true, completion: nil)
	}
	
    @objc func presentEditor(name: String, source: String?) {
		let editor = ScriptEditorViewController()
		editor.delegate = self
		editor.scriptName = name
        editor.importedSource = source
        self.navigationController?.pushViewController(editor, animated: (source == nil)) // Animate if no imported source
	}
	
	@objc func addScript(named name: String?, source: String?, injectionTime: Int) {
		guard let name = name else { return }
		guard let source = source else { return }
		
		do {
			try realm.write {
				let id = UUID().uuidString
				realm.add(ExtensionModel(value: ["source": source, "name": name,
				                                 "id": id, "active": true,
				                                 "injectionTime": injectionTime]))
			}
		} catch let error {
			logRealmError(error: error)
		}
	}
    
    @objc func toggleScript(sender: UISwitch) {
        guard let model = extensions?[sender.tag] else { return }
        
        do {
            try realm.write {
                model.active = sender.isOn
            }
        } catch let error {
            logRealmError(error: error)
        }
    }

}
