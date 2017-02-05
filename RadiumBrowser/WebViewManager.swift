//
//  WebViewManager.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/5/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import WebKit

class WebViewManager: NSObject {
	static let shared = WebViewManager()
	static let sharedProcessPool = WKProcessPool()
}
