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
	@objc dynamic var id = ""
    @objc dynamic var name = ""
	@objc dynamic var pageURL = ""
	@objc dynamic var iconURL = ""
	
	override static func indexedProperties() -> [String] {
		return ["name"]
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
}
