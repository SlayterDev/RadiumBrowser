//
//  TabView.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class TabView: UIView {
    
    var tabTitle: String? {
        didSet {
            tabTitleLabel?.text = tabTitle
        }
    }
    var tabTitleLabel: UILabel?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Colors.radiumGray
        
        tabTitleLabel = UILabel().then { [unowned self] in
            $0.text = "Google"
            
            self.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.blendCorner(corner: .All, length: 10)
    }

}
