//
//  MainViewController.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, HistoryNavigationDelegate {

	var container: UIView?
	var tabContainer: TabContainerView?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .gray
        
        let padding = UIView().then { [unowned self] in
            $0.backgroundColor = Colors.radiumDarkGray
            
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.width.equalTo(self.view)
                make.height.equalTo(22)
                make.top.equalTo(self.view)
            }
        }
        
        tabContainer = TabContainerView(frame: .zero).then { [unowned self] in
			$0.addTabButton?.addTarget(self, action: #selector(self.addTab), for: .touchUpInside)
			
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(padding.snp.bottom)
                make.left.equalTo(self.view)
                make.width.equalTo(self.view)
                make.height.equalTo(TabContainerView.standardHeight)
            }
        }
        
        let addressBar = AddressBar(frame: .zero).then { [unowned self] in
			$0.tabContainer = self.tabContainer
			self.tabContainer?.addressBar = $0
			
			$0.backButton?.addTarget(self.tabContainer!, action: #selector(self.tabContainer?.goBack(sender:)), for: .touchUpInside)
			$0.forwardButton?.addTarget(self.tabContainer!, action: #selector(self.tabContainer?.goForward(sender:)), for: .touchUpInside)
			$0.refreshButton?.addTarget(self.tabContainer!, action: #selector(self.tabContainer?.refresh(sender:)), for: .touchUpInside)
			$0.menuButton?.addTarget(self, action: #selector(self.showMenu(sender:)), for: .touchUpInside)
			
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(self.tabContainer!.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(AddressBar.standardHeight)
            }
        }
		
		container = UIView().then { [unowned self] in
            self.tabContainer?.containerView = $0
            
			self.view.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.top.equalTo(addressBar.snp.bottom)
				make.width.equalTo(self.view)
				make.bottom.equalTo(self.view)
				make.left.equalTo(self.view)
			}
		}

		tabContainer?.loadBrowsingSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        tabContainer?.setUpTabConstraints()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tabContainer?.setUpTabConstraints()
    }
    
	func addTab() {
		let _ = tabContainer?.addNewTab(container: container!)
	}
	
	func showMenu(sender: UIButton) {
		let shareAction = MenuItem.item(named: "Share", action: { [unowned self] in
			self.shareLink()
		})
        let extensionAction = MenuItem.item(named: "Extensions", action: { [unowned self] in
            self.showExtensions()
        })
		let historyAction = MenuItem.item(named: "History", action: { [unowned self] in
			self.showHistory()
		})
		
		let menu = SharedDropdownMenu(menuItems: [shareAction, extensionAction, historyAction])
		let convertedPoint = sender.convert(sender.center, to: self.view)
		menu.show(in: self.view, from: convertedPoint)
	}
	
	func shareLink() {
		guard let tabContainer = self.tabContainer else { return }
		let selectedTab = tabContainer.tabList[tabContainer.selectedTabIndex]
		
		guard let url = selectedTab.webContainer?.webView?.url else { return }
		let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
		activityVC.excludedActivityTypes = [.print]
		self.present(activityVC, animated: true, completion: nil)
	}
    
    func showExtensions() {
        let vc = ExtensionsTableViewController(style: .grouped)
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.barTintColor = Colors.radiumGray
        
        if isiPadUI {
            nav.modalPresentationStyle = .formSheet
        }
        
        self.present(nav, animated: true, completion: nil)
    }
	
	func showHistory() {
		let vc = HistoryTableViewController()
        vc.delegate = self
		let nav = UINavigationController(rootViewController: vc)
		nav.navigationBar.barTintColor = Colors.radiumGray
		
		if isiPadUI {
			nav.modalPresentationStyle = .formSheet
		}
		
		self.present(nav, animated: true, completion: nil)
	}
    
    func didSelectEntry(with url: URL?) {
        guard let url = url else { return }
        tabContainer?.loadQuery(string: url.absoluteString)
    }
}
