//
//  FaviconGetter.swift
//  RadiumBrowser
//
//  Created by bslayter on 2/8/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import WebKit

class FaviconGetter: BuiltinExtension, WKScriptMessageHandler {
    override var extensionName: String {
        return "Favicon Getter"
    }
    
    override init(container: WebContainer) {
        super.init(container: container)
        
        scriptHandlerName = "faviconsMessageHandler"
        
        if let path = Bundle.main.url(forResource: "Favicons", withExtension: "js") {
            if let source = try? String(contentsOf: path, encoding: .utf8) {
                let userscript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
                webScript = userscript
                container.webView?.configuration.userContentController.addUserScript(userscript)
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if let icons = message.body as? [String: Int] {
            for icon in icons {
                if icon.1 != 0 {
                    webContainer?.pageIconUrl = icon.0
                }
            }
        }
    }
}
