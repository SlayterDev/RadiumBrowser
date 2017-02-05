//
//  HistoryEntry.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/5/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import RealmSwift

class HistoryEntry: Object {
	dynamic var id = ""
	dynamic var pageURL = ""
	dynamic var pageTitle = ""
	dynamic var visitDate = Date(timeIntervalSince1970: 1)
	
	override class func primaryKey() -> String? {
		return "id"
	}
}
