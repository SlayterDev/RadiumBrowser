//
//  TabContainerView.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import WebKit

class TabContainerView: UIView, TabViewDelegate {
    
    static var currentInstance: TabContainerView?
    
    @objc static let standardHeight: CGFloat = 35
    
    @objc static let defaultTabWidth: CGFloat = 150
    @objc static let defaultTabHeight: CGFloat = TabContainerView.standardHeight - 2
    
    @objc weak var containerView: UIView?
    
    var tabCountButton: TabCountButton!
    var tabScrollView: UIScrollView!
    @objc lazy var tabList: [TabView] = []
	
	@objc var addTabButton: UIButton?
    
	@objc var selectedTabIndex = 0 {
		didSet {
			setTabColors()
		}
	}
    
    @objc var currentTab: TabView? {
        guard tabList.count > 0 else { return nil }
        return tabList[selectedTabIndex]
    }
	
	@objc weak var addressBar: AddressBar?
	
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
                if #available(iOS 11.0, *) {
                    make.right.equalTo(self.safeAreaLayoutGuide.snp.right).offset(-8)
                } else {
                    make.right.equalTo(self)
                }
			}
		}
        
        tabCountButton = TabCountButton().then {
            self.addSubview($0)
            $0.snp.makeConstraints { make in
                make.height.equalTo(TabContainerView.standardHeight - 5)
                make.width.equalTo(TabContainerView.standardHeight - 5)
                make.centerY.equalTo(self)
                if #available(iOS 11.0, *) {
                    make.left.equalTo(self.safeAreaLayoutGuide.snp.left).offset(8)
                } else {
                    make.left.equalTo(self).offset(4)
                }
            }
        }
        
        tabScrollView = UIScrollView().then {
            $0.isScrollEnabled = true
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            
            self.addSubview($0)
            $0.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.height.equalTo(TabContainerView.defaultTabHeight)
                make.left.equalTo(tabCountButton.snp.right).offset(5)
                make.right.equalTo(addTabButton!.snp.left).offset(-5)
            }
        }
        
        TabContainerView.currentInstance = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Tab Management
	
    @objc func addNewTab(container: UIView, focusAddressBar: Bool = true) -> TabView {
		let newTab = TabView(parentView: container).then { [unowned self] in
			$0.delegate = self
			
			self.tabScrollView.addSubview($0)
            self.tabScrollView.sendSubviewToBack($0)
        }
        tabList.append(newTab)
        
        setUpTabConstraints()
        didTap(tab: newTab)
        if focusAddressBar && tabList.count > 1 {
            addressBar?.addressField?.becomeFirstResponder()
        }
        
        scroll(toTab: newTab, addingTab: true)
        
        tabCountButton.updateCount(tabList.count)
        
        return newTab
    }
    
    @objc func addNewTab(withRequest request: URLRequest) {
        guard let container = self.containerView else { return }
        
        let newTab = addNewTab(container: container, focusAddressBar: false)
        let _ = newTab.webContainer?.webView?.load(request)
    }
    
    @objc func setUpTabConstraints() {
        let tabWidth = TabContainerView.defaultTabWidth
        
        for (i, tab) in tabList.enumerated() {
            tab.snp.remakeConstraints { (make) in
                make.top.bottom.equalTo(self.tabScrollView)
                make.height.equalTo(TabContainerView.defaultTabHeight)
                if i > 0 {
                    let lastTab = self.tabList[i - 1]
                    make.left.equalTo(lastTab.snp.right).offset(-6)
                } else {
                    make.left.equalTo(self.tabScrollView)
                }
                make.width.equalTo(tabWidth)
            }
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layoutIfNeeded()
        }) { _ in
            self.tabScrollView.contentSize = CGSize(width: TabContainerView.defaultTabWidth * CGFloat(self.tabList.count) -
                                               CGFloat((self.tabList.count - 1) * 6),
                                               height: TabContainerView.defaultTabHeight)
        }
    }
    
    @objc func setTabColors() {
        for (i, tab) in tabList.enumerated() {
            tab.backgroundColor = (i == selectedTabIndex) ? Colors.radiumGray : Colors.radiumUnselected
        }
    }
    
    func scroll(toTab tab: TabView, addingTab: Bool = false) {
        guard tabScrollView.contentSize.width > tabScrollView.frame.width else { return }
        
        let maxOffset = tabScrollView.contentSize.width - tabScrollView.frame.width + ((addingTab) ? TabContainerView.defaultTabWidth : 0)
        tabScrollView.setContentOffset(CGPoint(x: min(maxOffset, tab.frame.origin.x), y: 0), animated: true)
    }
	
	// MARK: - Tab Delegate
	
	@objc func didTap(tab: TabView) {
		let prevIndex = selectedTabIndex
		if let index = tabList.firstIndex(of: tab) {
			selectedTabIndex = index
			
			var prevTab: TabView?
			if tabList.count > 1 {
				prevTab = tabList[prevIndex]
			}
			
			switchVisibleWebView(prevTab: prevTab, newTab: tab)
            
            scroll(toTab: tab)
		}
	}
	
	@objc func switchVisibleWebView(prevTab: TabView?, newTab: TabView) {
		prevTab?.webContainer?.removeFromView()
		newTab.webContainer?.addToView()
        
        let attrUrl = WebViewManager.shared.getColoredURL(url: newTab.webContainer?.webView?.url)
        if attrUrl.string != "" {
            addressBar?.setAttributedAddressText(attrUrl)
        } else {
            addressBar?.setAddressText(newTab.webContainer?.webView?.url?.absoluteString)
        }
	}
	
	@objc func close(tab: TabView) -> Bool {
        guard tabList.count > 1 else { return false }
        guard let indexToRemove = tabList.firstIndex(of: tab) else { return false }
        
        tabList.remove(at: indexToRemove)
        tab.removeFromSuperview()
        if selectedTabIndex >= indexToRemove {
            selectedTabIndex = max(0, selectedTabIndex - 1)
            switchVisibleWebView(prevTab: tab, newTab: tabList[selectedTabIndex])
        }
        
        setUpTabConstraints()
        
        tabCountButton.updateCount(tabList.count)
        
        return true
	}
	
	// MARK: - Web Navigation
	
	@objc func loadQuery(string: String?) {
		guard let string = string else { return }
		
        if addressBar?.addressField?.text != string {
            addressBar?.setAddressText(string)
        }
        
		let tab = tabList[selectedTabIndex]
		tab.webContainer?.loadQuery(string: string)
	}
	
	@objc func goBack(sender: UIButton) {
		let tab = tabList[selectedTabIndex]
		let _ = tab.webContainer?.webView?.goBack()
        tab.webContainer?.finishedLoadUpdates()
    }
	
	@objc func goForward(sender: UIButton) {
		let tab = tabList[selectedTabIndex]
		let _ = tab.webContainer?.webView?.goForward()
        tab.webContainer?.finishedLoadUpdates()
	}
	
	@objc func refresh(sender: UIButton) {
		let tab = tabList[selectedTabIndex]
		let _ = tab.webContainer?.webView?.reload()
	}
	
	@objc func updateNavButtons() {
		let tab = tabList[selectedTabIndex]
		
		addressBar?.backButton?.isEnabled = tab.webContainer?.webView?.canGoBack ?? false
        addressBar?.backButton?.tintColor = (tab.webContainer?.webView?.canGoBack ?? false) ? .black : .lightGray
		addressBar?.forwardButton?.isEnabled = tab.webContainer?.webView?.canGoForward ?? false
        addressBar?.forwardButton?.tintColor = (tab.webContainer?.webView?.canGoForward ?? false) ? .black : .lightGray
	}
	
	// MARK: - Data Managment
	
	@objc func saveBrowsingSession() {
		let session = BrowsingSession()
		let models = List<URLModel>()
		for tab in tabList {
			let model = URLModel()
			model.urlString = tab.webContainer?.webView?.url?.absoluteString ?? ""
			model.pageTitle = tab.tabTitle ?? ""
			models.append(model)
		}
		session.tabs.append(objectsIn: models)
		session.selectedTabIndex = selectedTabIndex
		
		do {
			let realm = try Realm()
			try realm.write {
				let _ = models.map {
					realm.add($0)
				}
				realm.add(session)
			}
		} catch let error {
			logRealmError(error: error)
		}
	}
	
	@objc func loadBrowsingSession() {
		var tabModels: List<URLModel>?
		var session: BrowsingSession?
		var realm: Realm?
		do {
			realm = try Realm()
			session = realm?.objects(BrowsingSession.self).first
			tabModels = session?.tabs
		} catch let error {
			logRealmError(error: error)
		}
		
		guard tabModels != nil else {
			let _ = addNewTab(container: containerView!)
			return
		}
		
		for model in tabModels! {
			let request = URLRequest(url: URL(string: model.urlString)!)
			addNewTab(withRequest: request)
		}
		didTap(tab: tabList[session!.selectedTabIndex])
		
		// Remove data from database
		do {
			try realm?.write {
				realm?.delete(tabModels!)
				realm?.delete(session!)
			}
		} catch let error {
			logRealmError(error: error)
		}
	}
}
