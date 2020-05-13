//
//  WebServer.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/1/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation
import GCDWebServer
import RealmSwift

class WebServer {
    static let shared = WebServer()
    
    let webServer = GCDWebServer()
    
    let newTabHTMLStart = """
        <!DOCTYPE html>
        <html>
        <head>
            <title>New Tab</title>
            <style type="text/css">
                * {
                    font-family: sans-serif;
                }

                h1 {
                    padding-top: 72px;
                    font-size: 72px;
                }

                #noBookmark {
                    padding-top: 144px;
                    font-size: 48px;
                }
                
                .bookmarkTitle {
                    margin: 0;
                    font-size: 36px;
                    overflow: hidden;
                    display: -webkit-box;
                    -webkit-line-clamp: 1;
                    -webkit-box-orient: vertical;
                }

                .container {
                    padding-top: 144px;
                    padding-left: 5%;
                    padding-right: 5%;
                }
                
                .floatBlock {
                    display: inline-block;
                    float: left;
                    width: 33%;
                    padding-bottom: 33%
                }

                a img {
                    display: block;
                    margin: auto;
                }

                .footer {
                    background: #EFEFEF;
                    position: fixed;
                    bottom: 0;
                    width: 100%;
                    height: 100px;
                    font-size: 28px;
                    margin: 0;
                    padding-bottom: env(safe-area-inset-bottom);
                }
            </style>
        </head>
        <body>
            <h1 align="center">New Tab</h1>
        """
    let newTabEnd = """
        <div class="footer">
            <p align=\"center\">Radium Web Browser v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.1") (\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0"))</p>
        </div>
        </body></html>
        """
    
    init() {
        webServer.addDefaultHandler(forMethod: "GET", request: GCDWebServerRequest.self, processBlock: { _  in
            return GCDWebServerDataResponse(html: self.getNewTabHTMLString())
        })
        webServer.addHandler(forMethod: "GET", path: "/noimage", request: GCDWebServerRequest.self, processBlock: { _ in
            let img = #imageLiteral(resourceName: "globe")
            return GCDWebServerDataResponse(data: img.pngData()!, contentType: "image/png")
        })
        webServer.addHandler(forMethod: "GET", path: "/favicon.ico", request: GCDWebServerRequest.self, processBlock: { _ in
            let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? NSDictionary
            let primaryIconsDictionary = iconsDictionary?["CFBundlePrimaryIcon"] as? NSDictionary
            let iconFiles = primaryIconsDictionary!["CFBundleIconFiles"] as! NSArray
            // First will be smallest for the device class, last will be the largest for device class
            let lastIcon = iconFiles.lastObject as! NSString
            let icon = UIImage(named: lastIcon as String)!
            return GCDWebServerDataResponse(data: icon.pngData()!, contentType: "image/png")
        })
    }
    
    func startServer() {
        webServer.start(withPort: 8080, bonjourName: nil)
    }
    
    func getNewTabHTMLString() -> String {
        var result = newTabHTMLStart
        
        let bookmarks: Results<Bookmark>?
        do {
            let realm = try Realm()
            bookmarks = realm.objects(Bookmark.self)
        } catch {
            bookmarks = nil
            print("Error: \(error.localizedDescription)")
        }
        
        if let bookmarks = bookmarks, bookmarks.count > 0 {
            result += "<div class=\"container\">"
            for i in 0..<min(6, bookmarks.count) {
                let iconLoc = (bookmarks[i].iconURL == "") ? "http://localhost:8080/noimage" : bookmarks[i].iconURL
                result += """
                    <div class="floatBlock">
                <a href="\(bookmarks[i].pageURL)"><img src="\(iconLoc)" onerror=\"this.src='/noimage';\" width=200px height=200px></a>
                    <p class="bookmarkTitle" align=\"center\">\(bookmarks[i].name)</p>
                    </div>
                """
            }
            result += "</div>"
        } else {
            result += "<p id=\"noBookmark\" align=\"center\">Go add some bookmarks to see them here!</p>"
        }
        
        return result + newTabEnd
    }
}
