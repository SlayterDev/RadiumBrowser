//
//  TabContainerView.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class TabContainerView: UIView {
    
    static let standardHeight: CGFloat = 40
    
    static let defaultTabWidth: CGFloat = 150
    static let defaultTabHeight: CGFloat = TabContainerView.standardHeight - 4
    
    lazy var tabList: [TabView] = []
    
    var selectedTabIndex = 1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Colors.radiumDarkGray
        addNewTab()
        addNewTab()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addNewTab() {
        let newTab = TabView(frame: .zero).then { [unowned self] in
            self.addSubview($0)
            self.sendSubview(toBack: $0)
            $0.snp.makeConstraints { (make) in
                make.bottom.equalTo(self)
                make.height.equalTo(TabContainerView.defaultTabHeight)
                if let lastTab = self.tabList.last {
                    make.left.equalTo(lastTab.snp.right).offset(-6)
                } else {
                    make.left.equalTo(self)
                }
                make.width.equalTo(TabContainerView.defaultTabWidth)
            }
        }
        tabList.append(newTab)
        setTabColors()
    }
    
    func setTabColors() {
        for (i, tab) in tabList.enumerated() {
            if i == selectedTabIndex {
                tab.backgroundColor = Colors.radiumGray
            } else {
                tab.backgroundColor = Colors.radiumUnselected
            }
        }
    }

}
