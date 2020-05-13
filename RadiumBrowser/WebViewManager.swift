//
//  WebViewManager.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/5/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import WebKit

typealias ScriptHandler = (WKUserContentController, WKScriptMessage) -> ()

class WebViewManager: NSObject {
	@objc static let shared = WebViewManager()
	@objc static let sharedProcessPool = WKProcessPool()
	
	@objc func logPageVisit(url: String?, pageTitle: String?) {
        if let urlString = url, let urlObj = URL(string: urlString), urlObj.host == "localhost" {
            // We don't want to log any pages we serve ourselves
            return
        }
        
        // Check if we should be logging page visits
        if !UserDefaults.standard.bool(forKey: SettingsKeys.trackHistory) {
            return
        }
        
		let entry = HistoryEntry()
		entry.id = UUID().uuidString
		entry.pageURL = url ?? ""
		entry.pageTitle = pageTitle ?? ""
		entry.visitDate = Date()
		
		do {
			let realm = try Realm()
			try realm.write {
				realm.add(entry)
			}
		} catch let error {
			logRealmError(error: error)
		}
	}
	
	@objc func getColoredURL(url: URL?) -> NSAttributedString {
		guard let url = url else { return NSAttributedString(string: "") }
        guard let _ = url.host else { return NSAttributedString(string: "") }
		let urlString = url.absoluteString as NSString
		
		let mutableAttributedString = NSMutableAttributedString(string: urlString as String,
                                                                attributes: convertToOptionalNSAttributedStringKeyDictionary(["foregroundColor": UIColor.gray]))
		if url.scheme == "https" {
			let range = urlString.range(of: url.scheme!)
			mutableAttributedString.addAttribute(convertToNSAttributedStringKey("foregroundColor"), value: Colors.urlGreen, range: range)
		}
        
		let domainRange = urlString.range(of: url.host!)
		mutableAttributedString.addAttribute(convertToNSAttributedStringKey("foregroundColor"), value: UIColor.black, range: domainRange)
		
		return mutableAttributedString
	}
    
    @objc func loadBuiltinExtensions(webContainer: WebContainer) -> [BuiltinExtension] {
        let faviconGetter = FaviconGetter(container: webContainer)
        
        return [faviconGetter]
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSAttributedStringKey(_ input: String) -> NSAttributedString.Key {
	return NSAttributedString.Key(rawValue: input)
}
