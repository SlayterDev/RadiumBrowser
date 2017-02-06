//
//  MigrationManager.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/5/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

class MigrationManager: NSObject {
	static let shared = MigrationManager()
	
	func attemptMigration() {
		let realmConfig = Realm.Configuration(
			schemaVersion: 4,
			migrationBlock: { migration, oldSchemaVersion in
				if oldSchemaVersion < 1 {
					migration.enumerateObjects(ofType: ExtensionModel.className()) { oldObject, newObject in
						newObject?["active"] = true
					}
				}
				
				if oldSchemaVersion < 2 {
					migration.enumerateObjects(ofType: BrowsingSession.className()) { oldObject, newObject in
						newObject?["selectedTabIndex"] = 0
					}
				}
				
				if oldSchemaVersion < 3 {
					migration.enumerateObjects(ofType: ExtensionModel.className()) { oldObject, newObject in
						newObject?["injectionTime"] = 1
					}
				}
                
                if oldSchemaVersion < 4 {
                    migration.enumerateObjects(ofType: BrowsingSession.className()) { oldObject, newObject in
                        newObject?["selectedTabIndex"] = 0
                    }
                }
			}
		)
		
		Realm.Configuration.defaultConfiguration = realmConfig
	}
}
