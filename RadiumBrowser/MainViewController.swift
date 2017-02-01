//
//  MainViewController.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

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
			
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(self.tabContainer!.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(AddressBar.standardHeight)
            }
        }
		
		container = UIView().then { [unowned self] in
			self.view.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.top.equalTo(addressBar.snp.bottom)
				make.width.equalTo(self.view)
				make.bottom.equalTo(self.view)
				make.left.equalTo(self.view)
			}
		}
		
		tabContainer?.addNewTab(container: container!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

	func addTab() {
		tabContainer?.addNewTab(container: container!)
	}

}
