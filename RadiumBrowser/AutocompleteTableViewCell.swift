//
//  AutocompleteTableViewCell.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/1/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import LUAutocompleteView

class AutocompleteTableViewCell: LUAutocompleteTableViewCell {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        detailTextLabel?.textColor = .gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func set(text: String) {
        textLabel?.text = text
        DispatchQueue.global().async {
            let pageTitle = SuggestionManager.shared.pageTitle(forURLSring: text)
            DispatchQueue.main.async {
                self.detailTextLabel?.text = pageTitle
            }
        }
    }
}
