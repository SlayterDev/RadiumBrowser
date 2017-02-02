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
}
