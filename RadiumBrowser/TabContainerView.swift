//
//  TabContainerView.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class TabContainerView: UIView, TabViewDelegate {
    
    static let standardHeight: CGFloat = 35
    
    static let defaultTabWidth: CGFloat = 150
    static let defaultTabHeight: CGFloat = TabContainerView.standardHeight - 2
    
    lazy var tabList: [TabView] = []
	
	var addTabButton: UIButton?
    
	var selectedTabIndex = 0 {
		didSet {
			setTabColors()
		}
	}
	
	weak var addressBar: AddressBar?
		
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Colors.radiumDarkGray
		
		addTabButton = UIButton().then { [unowned self] in
			$0.setImage(UIImage.imageFrom(systemItem: .add), for: .normal)
			
			self.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.height.equalTo(TabContainerView.standardHeight - 5)
				make.width.equalTo(TabContainerView.standardHeight - 5)
				make.centerY.equalTo(self)
				make.right.equalTo(self).offset(-8)
			}
		}
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
	
	func addNewTab(container: UIView) {
		let newTab = TabView(parentView: container).then { [unowned self] in
			$0.delegate = self
			
			self.addSubview($0)
            self.sendSubview(toBack: $0)
        }
        tabList.append(newTab)
        didTap(tab: newTab)
        setUpTabConstraints()
    }
    
    func setUpTabConstraints() {
        for (i, tab) in tabList.enumerated() {
            let tabWidth = min(TabContainerView.defaultTabWidth, self.frame.width / CGFloat(tabList.count))// - (TabContainerView.defaultTabHeight - 10))
            tab.snp.remakeConstraints { (make) in
                make.bottom.equalTo(self)
                make.height.equalTo(TabContainerView.defaultTabHeight)
                if i > 0 {
                    let lastTab = self.tabList[i - 1]
                    make.left.equalTo(lastTab.snp.right).offset(-6)
                } else {
                    make.left.equalTo(self)
                }
                make.width.equalTo(tabWidth)
            }
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
        })
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
	
	// MARK: - Tab Delegate
	
	func didTap(tab: TabView) {
		let prevIndex = selectedTabIndex
		if let index = tabList.index(of: tab) {
			selectedTabIndex = index
			
			var prevTab: TabView?
			if tabList.count > 1 {
				prevTab = tabList[prevIndex]
			}
			
			switchVisibleWebView(prevTab: prevTab, newTab: tab)
		}
	}
	
	func switchVisibleWebView(prevTab: TabView?, newTab: TabView) {
		prevTab?.webContainer?.removeFromView()
		newTab.webContainer?.addToView()
		addressBar?.addressField?.text = newTab.webContainer?.webView?.url?.absoluteString
	}
	
	func close(tab: TabView) {
        guard tabList.count > 1 else { return }
        guard let indexToRemove = tabList.index(of: tab) else { return }
        
        tabList.remove(at: indexToRemove)
        tab.removeFromSuperview()
        if selectedTabIndex >= indexToRemove {
            selectedTabIndex = max(0, selectedTabIndex - 1)
            switchVisibleWebView(prevTab: tab, newTab: tabList[selectedTabIndex])
        }
        
        setUpTabConstraints()
	}
	
	// MARK: - Web Navigation
	
	func loadQuery(string: String?) {
		guard let string = string else { return }
		
		let tab = tabList[selectedTabIndex]
		tab.webContainer?.loadQuery(string: string)
	}
	
	func goBack(sender: UIButton) {
		let tab = tabList[selectedTabIndex]
		let _ = tab.webContainer?.webView?.goBack()
	}
	
	func goForward(sender: UIButton) {
		let tab = tabList[selectedTabIndex]
		let _ = tab.webContainer?.webView?.goForward()
	}
	
	func refresh(sender: UIButton) {
		let tab = tabList[selectedTabIndex]
		let _ = tab.webContainer?.webView?.reload()
	}
	
	func updateNavButtons() {
		let tab = tabList[selectedTabIndex]
		
		addressBar?.backButton?.isEnabled = tab.webContainer?.webView?.canGoBack ?? false
		addressBar?.forwardButton?.isEnabled = tab.webContainer?.webView?.canGoForward ?? false
	}
}
