//
//  TabView.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

protocol TabViewDelegate {
	func didTap(tab: TabView)
}

class TabView: UIView {
    
    var tabTitle: String? {
        didSet {
            tabTitleLabel?.text = tabTitle
        }
    }
    var tabTitleLabel: UILabel?
	
	var delegate: TabViewDelegate?
	
	var webContainer: WebContainer?

	init(parentView: UIView) {
        super.init(frame: .zero)
        
        self.backgroundColor = Colors.radiumGray
        
        tabTitleLabel = UILabel().then { [unowned self] in
            $0.text = "New Tab"
            
            self.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.equalTo(self).inset(UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16))
            }
        }
		
		let gesture = UITapGestureRecognizer()
		gesture.numberOfTapsRequired = 1
		gesture.addTarget(self, action: #selector(tappedTab))
		self.addGestureRecognizer(gesture)
		self.isUserInteractionEnabled = true
		
		webContainer = WebContainer(parent: parentView)
		webContainer?.tabView = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.blendCorner(corner: .All, length: 10)
    }
	
	func tappedTab(sender: UITapGestureRecognizer) {
		delegate?.didTap(tab: self)
	}
}
