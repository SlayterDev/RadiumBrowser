//
//  SharedConfig.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import UIKit
import BSColorUtils

struct Colors {
    static let radiumGray = UIColor.with(hex: "#EFEFEF")
    static let radiumDarkGray = UIColor.with(hex: "#AFB4B4")
    static let radiumUnselected = UIColor.with(hex: "#C8C8C8")
    static let urlGreen = UIColor.with(hex: "#046D23")
}

let isiPadUI = UI_USER_INTERFACE_IDIOM() == .pad

func logRealmError(error: Error) {
	print("## Realm Error: \(error.localizedDescription)")
}

func * (lhs: String, rhs: Int) -> String {
    guard rhs > 0 else { return "" }
    
    var result = ""
    for _ in 0..<rhs {
        result += lhs
    }
    
    return result
}
