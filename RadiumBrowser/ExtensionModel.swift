//
//  ExtensionModel.swift
//  RadiumBrowser
//
//  Created by bslayter on 2/2/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import RealmSwift

class ExtensionModel: Object {
    dynamic var source = ""
    dynamic var id = ""
    dynamic var name = ""
    dynamic var active = true
	dynamic var injectionTime = 1 // 0 == Start, 1 == End
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
