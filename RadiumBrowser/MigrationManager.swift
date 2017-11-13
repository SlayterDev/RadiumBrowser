//
//  MigrationManager.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/5/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftKeychainWrapper

class MigrationManager: NSObject {
	@objc static let shared = MigrationManager()
	
	@objc func attemptMigration() {
		let realmConfig = Realm.Configuration(
			schemaVersion: 6,
			migrationBlock: { migration, oldSchemaVersion in
				if oldSchemaVersion < 1 {
					migration.enumerateObjects(ofType: ExtensionModel.className()) { _, newObject in
						newObject?["active"] = true
					}
				}
				
				if oldSchemaVersion < 2 {
					migration.enumerateObjects(ofType: BrowsingSession.className()) { _, newObject in
						newObject?["selectedTabIndex"] = 0
					}
				}
				
				if oldSchemaVersion < 3 {
					migration.enumerateObjects(ofType: ExtensionModel.className()) { _, newObject in
						newObject?["injectionTime"] = 1
					}
				}
                
                if oldSchemaVersion < 4 {
                    migration.enumerateObjects(ofType: BrowsingSession.className()) { _, newObject in
                        newObject?["selectedTabIndex"] = 0
                    }
                }
				
				if oldSchemaVersion < 5 {
					migration.enumerateObjects(ofType: Bookmark.className()) { _, newObject in
						newObject?["iconURL"] = ""
					}
				}
                
                // Using this to grand father current users in for ad blocking
                if #available(iOS 11.0, *), oldSchemaVersion < 6 {
                    KeychainWrapper.standard.set(true, forKey: SettingsKeys.adBlockPurchased)
                    UserDefaults.standard.set(true, forKey: SettingsKeys.needToShowAdBlockAlert)
                    UserDefaults.standard.set(true, forKey: SettingsKeys.adBlockEnabled)
                }
			}
		)
		
		Realm.Configuration.defaultConfiguration = realmConfig
        
        if !UserDefaults.standard.bool(forKey: "cloudToButtAdded") {
            if let filePath = Bundle.main.path(forResource: "CloudToButt", ofType: "js"),
                let content = try? String(contentsOfFile: filePath, encoding: .utf8) {
                UserDefaults.standard.set(true, forKey: "cloudToButtAdded")
                
                let exten = ExtensionModel()
                exten.id = UUID().uuidString
                exten.name = "Cloud To Butt"
                exten.source = content
                exten.active = false
                
                do {
                    let realm = try Realm()
                    try realm.write {
                        realm.add(exten)
                    }
                } catch {
                    print("Realm error: \(error.localizedDescription)")
                }
            }
        }
	}
}
