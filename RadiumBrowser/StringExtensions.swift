//
//  StringExtensions.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import Foundation

/// Duplicate a string n number of times.
///
/// - Parameters:
///   - lhs: The string to duplicate
///   - rhs: The number of times to duplicate the string
/// - Returns: The resulting string
func * (lhs: String, rhs: Int) -> String {
    guard rhs > 0 else { return "" }
    
    var result = ""
    for _ in 0..<rhs {
        result += lhs
    }
    
    return result
}

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
    
    func getIndentationLevel(tabSize: Int) -> Int {
        guard tabSize > 0 else { return 0 }
        
        let formattedString = self.replacingOccurrences(of: "\t", with: " " * tabSize)
        
        return formattedString.countLeadingSpaces() / tabSize
    }
}
