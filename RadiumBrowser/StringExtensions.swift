//
//  StringExtensions.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation

extension String {
	func isURL() -> Bool {
        if self.hasPrefix("https://") || self.hasPrefix("http://") {
            return true
        }
        
		return self.range(of: "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$", options: .regularExpression) != nil
	}
    
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
    
    func countLeadingSpaces() -> Int {
        guard !isEmpty else { return 0 }
        
        var i = startIndex
        var count = 0
        while i < endIndex {
            let c = self[i]
            if c == " " {
                count += 1
            } else {
                break
            }
            i = self.index(i, offsetBy: 1)
        }
        
        return count
    }
    
    func getIndentationLevel() -> Int {
        return countLeadingSpaces() / 4
    }
}
