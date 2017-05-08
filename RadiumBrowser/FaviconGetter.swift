//
//  FaviconGetter.swift
//  RadiumBrowser
//
//  Created by bslayter on 2/8/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import WebKit

enum FaviconType: Int {
    case icon = 0
    case apple = 1
    case applePrecomposed = 2
    case guess = 3
}

struct Favicon {
    var iconURL: String?
    var appleURL: String?
    var applePrecomposed: String?
    var guess: String?
    
    func getPreferredURL() -> String? {
        if let applePrecomposed = applePrecomposed {
            return applePrecomposed
        } else if let appleURL = appleURL {
            return appleURL
        } else if let iconURL = iconURL {
            return iconURL
        } else if let guess = guess {
            return guess
        }
        
        return nil
    }
}

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
        guard let icons = message.body as? [String: Int] else { return }
        
        var favicon = Favicon()
        for icon in icons {
            guard let type = FaviconType(rawValue: icon.1) else { continue }
            switch type {
            case .icon:
                favicon.iconURL = icon.0
            case .apple:
                favicon.appleURL = icon.0
            case .applePrecomposed:
                favicon.applePrecomposed = icon.0
            case .guess:
                favicon.guess = icon.0
            }
        }
        
        webContainer?.favicon = favicon
    }
}
