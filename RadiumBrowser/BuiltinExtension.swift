//
//  BuiltinExtension.swift
//  RadiumBrowser
//
//  Created by bslayter on 2/8/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import WebKit

protocol UserScriptHandler {
    var scriptMessageHandler: ScriptHandler { get }
}

class BuiltinExtension: NSObject {
    var extensionName: String {
        return "UNNAMED"
    }
    
    var scriptHandlerName: String?
    
    var webContainer: WebContainer?
    var webScript: WKUserScript?
    
    init(container: WebContainer) {
        super.init()
        
        webContainer = container
    }
}
