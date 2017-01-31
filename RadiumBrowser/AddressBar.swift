//
//  AddressBar.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class AddressBar: UIView {
    
    static let standardHeight: CGFloat = 44
    
    var addressField: UITextField?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Colors.radiumGray
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
        
        addressField = SharedTextField().then { [unowned self] in
            $0.placeholder = "Address"
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.borderWidth = 0.5
            $0.layer.cornerRadius = 4
            $0.inset = 8
            
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.keyboardType = .URL
            
            self.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(self).inset(8)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
