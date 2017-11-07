//
//  SuggestionManager.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/1/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import RealmSwift

struct URLEntry: Hashable {
    var hashValue: Int {
        return urlString.hashValue
    }
    
    static func ==(lhs: URLEntry, rhs: URLEntry) -> Bool {
        return lhs.urlString == rhs.urlString
    }
    
    var urlString: String
    var titleString: String?
}

class SuggestionManager {
    static let shared = SuggestionManager()
    
    lazy var domainSet = OrderedSet<URLEntry>()
    
    var topdomains: [URLEntry]?
    var historyResults: Results<HistoryEntry>?
    
    @objc var notificationToken: NotificationToken!
    var realm: Realm!
    
    deinit {
        notificationToken.stop()
    }
    
    init() {
        defer {
            reupdateList()
        }
        
        guard let path = Bundle.main.path(forResource: "topdomains", ofType: "txt") else {
            return
        }
        
        do {
            self.realm = try Realm()
            self.historyResults = realm.objects(HistoryEntry.self)
            self.notificationToken = historyResults?.addNotificationBlock { [weak self] _ in
                self?.reupdateList()
            }
        } catch let error as NSError {
            print("Error occured opening realm: \(error.localizedDescription)")
        }
        
        do {
            let domainConent = try String(contentsOfFile: path, encoding: .utf8)
            let domainList = domainConent.components(separatedBy: "\n")
            
            topdomains = domainList.map { URLEntry(urlString: $0, titleString: nil) }
        } catch {
            return
        }
        
    }
    
    func reupdateList() {
        domainSet.removeAllObjects()
        
        domainSet.append(contentsOf: topdomains!)
        historyResults?.forEach { domainSet.append(URLEntry(urlString: $0.pageURL, titleString: $0.pageTitle)) }
    }
    
    func queryDomains(forText text: String) -> [URLEntry] {
        var queryText = text.replacingOccurrences(of: "http://", with: "")
        queryText = text.replacingOccurrences(of: "https://", with: "")
        
        let results: [URLEntry] = domainSet.filter { $0.urlString.contains(queryText) }
        
        return results
    }
    
    func pageTitle(forURLSring urlString: String) -> String? {
        for entry in domainSet where entry.urlString == urlString {
            return entry.titleString
        }
        
        return nil
    }
}
