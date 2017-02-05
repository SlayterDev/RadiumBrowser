//
//  WebViewManager.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/5/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import WebKit

class WebViewManager: NSObject {
	static let shared = WebViewManager()
	static let sharedProcessPool = WKProcessPool()
	
	func logPageVisit(url: String?, pageTitle: String?) {
		let entry = HistoryEntry()
		entry.id = UUID().uuidString
		entry.pageURL = url ?? ""
		entry.pageTitle = pageTitle ?? ""
		entry.visitDate = Date()
		
		do {
			let realm = try Realm()
			try realm.write {
				realm.add(entry)
			}
		} catch let error {
			logRealmError(error: error)
		}
	}
}
