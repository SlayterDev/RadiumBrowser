//
//  TabContainerView.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

class TabContainerView: UIView, TabViewDelegate {
    
    static let standardHeight: CGFloat = 35
    
    static let defaultTabWidth: CGFloat = 150
    static let defaultTabHeight: CGFloat = TabContainerView.standardHeight - 2
    
    weak var containerView: UIView?
    
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
		
		if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
			appDelegate.tabContainer = self
		}
		
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
    
    // MARK: - Tab Management
	
	func addNewTab(container: UIView) -> TabView {
		let newTab = TabView(parentView: container).then { [unowned self] in
			$0.delegate = self
			
			self.addSubview($0)
            self.sendSubview(toBack: $0)
        }
        tabList.append(newTab)
        didTap(tab: newTab)
        setUpTabConstraints()
        
        return newTab
    }
    
    func addNewTab(withRequest request: URLRequest) {
        guard let container = self.containerView else { return }
        
        let newTab = addNewTab(container: container)
        let _ = newTab.webContainer?.webView?.load(request)
    }
    
    func setUpTabConstraints() {
        let tabWidth = min(TabContainerView.defaultTabWidth,
                           (self.frame.width - TabContainerView.standardHeight + CGFloat(tabList.count * 6) - 5) / CGFloat(tabList.count))
        
        for (i, tab) in tabList.enumerated() {
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
	
	// MARK: - Data Managment
	
	func saveBrowsingSession() {
		let session = BrowsingSession()
		let models = List<URLModel>()
		for tab in tabList {
			let model = URLModel()
			model.urlString = tab.webContainer?.webView?.url?.absoluteString ?? ""
			model.pageTitle = tab.tabTitle ?? ""
			models.append(model)
		}
		session.tabs.append(objectsIn: models)
		session.selectedTabIndex = Int32(selectedTabIndex)
		
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
	
	func loadBrowsingSession() {
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
		didTap(tab: tabList[Int(session!.selectedTabIndex)])
		
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
