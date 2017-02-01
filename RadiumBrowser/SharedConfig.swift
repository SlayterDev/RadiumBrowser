//
//  SharedConfig.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import UIKit

struct Colors {
    static let radiumGray = UIColor(red: 0.937, green: 0.937, blue: 0.937, alpha: 1.0)
    static let radiumDarkGray = UIColor(red: 0.686, green: 0.706, blue: 0.706, alpha: 1.0)
    static let radiumUnselected = UIColor(red: 0.784, green: 0.784, blue: 0.784, alpha: 1.0)
}

struct Tags {
    static let tabOutlineTag = 999
}

let isiPadUI = UI_USER_INTERFACE_IDIOM() == .pad
