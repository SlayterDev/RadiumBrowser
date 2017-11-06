//
//  AdBlockManager.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/4/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import WebKit

class AdBlockManager {
    static let shared = AdBlockManager()
    
    @available(iOS 11.0, *)
    func setupAdBlock(forWebView webView: WKWebView?, completion: (() -> Void)?) {
        if UserDefaults.standard.bool(forKey: SettingsKeys.adBlockLoaded) {
            WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: SettingsKeys.adBlockLoaded) { [weak self] ruleList, error in
                if let error = error {
                    print(error.localizedDescription)
                    UserDefaults.standard.set(false, forKey: SettingsKeys.adBlockLoaded)
                    self?.setupAdBlock(forWebView: webView, completion: completion)
                    return
                }
                if let list = ruleList {
                    webView?.configuration.userContentController.add(list)
                    completion?()
                }
            }
        } else {
            if let jsonPath = Bundle.main.path(forResource: "adaway", ofType: "json"), let jsonContent = try? String(contentsOfFile: jsonPath, encoding: .utf8) {
                WKContentRuleListStore.default().compileContentRuleList(forIdentifier: SettingsKeys.adBlockLoaded, encodedContentRuleList: jsonContent) { ruleList, error in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    if let list = ruleList {
                        webView?.configuration.userContentController.add(list)
                        UserDefaults.standard.set(true, forKey: SettingsKeys.adBlockLoaded)
                        completion?()
                    }
                }
            }
        }
    }
    
    @available(iOS 11.0, *)
    func setupAdBlockFromStringLiteral(forWebView webView: WKWebView?, completion: (() -> Void)?) {
        // Swift 4  Multi-line string literals
        let jsonString = """
[{
  "trigger": {
    "url-filter": "://googleads\\\\.g\\\\.doubleclick\\\\.net.*"
  },
  "action": {
    "type": "block"
  }
}]
"""
        if UserDefaults.standard.bool(forKey: SettingsKeys.stringLiteralAdBlock) {
            // list should already be compiled
            WKContentRuleListStore.default().lookUpContentRuleList(forIdentifier: SettingsKeys.stringLiteralAdBlock) { [weak self] (contentRuleList, error) in
                if let error = error {
                    print(error.localizedDescription)
                    UserDefaults.standard.set(false, forKey: SettingsKeys.stringLiteralAdBlock)
                    self?.setupAdBlockFromStringLiteral(forWebView: webView, completion: completion)
                    return
                }
                if let list = contentRuleList {
                    webView?.configuration.userContentController.add(list)
                    completion?()
                }
            }
        } else {
            WKContentRuleListStore.default().compileContentRuleList(forIdentifier: SettingsKeys.stringLiteralAdBlock, encodedContentRuleList: jsonString) { contentRuleList, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                if let list = contentRuleList {
                    webView?.configuration.userContentController.add(list)
                    UserDefaults.standard.set(true, forKey: SettingsKeys.stringLiteralAdBlock)
                    completion?()
                }
            }
        }
    }
    
    func shouldBlockAds() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: SettingsKeys.adBlockPurchased) && defaults.bool(forKey: SettingsKeys.adBlockEnabled)
    }
    
    @available(iOS 11.0, *)
    func disableAdBlock(forWebView webView: WKWebView?) {
        webView?.configuration.userContentController.removeAllContentRuleLists()
    }
}
