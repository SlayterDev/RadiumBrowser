//
//  Bookmark.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/6/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import RealmSwift

class Bookmark: Object {
	dynamic var id = ""
    dynamic var name = ""
	dynamic var pageURL = ""
	dynamic var iconURL = ""
	
	override static func indexedProperties() -> [String] {
		return ["name"]
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
