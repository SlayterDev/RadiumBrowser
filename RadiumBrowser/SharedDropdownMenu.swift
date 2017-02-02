//
//  SharedDropdownMenu.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/1/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

struct MenuItem {
	var name: String?
	var action: (() -> ())?
	
	static func item(named name: String, action: (() ->())?) -> MenuItem {
		var menuItem = MenuItem()
		menuItem.name = "  " + name
		menuItem.action = action
		return menuItem
	}
}

class SharedDropdownMenu: UIView {
	
	static let defaultMenuItemHeight: CGFloat = 44
	static let defaultMenuWidth: CGFloat = 250
	
	var menuItems: [MenuItem]?
	
	init(menuItems: [MenuItem]) {
		super.init(frame: .zero)
		
		self.layer.cornerRadius = 4
		self.layer.borderColor = UIColor.gray.cgColor
		self.layer.borderWidth = 0.25
		self.clipsToBounds = true
		
		self.menuItems = menuItems
		setupMenu()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupMenu() {
		var itemViews = [UIView]()
		for (i, menuItem) in menuItems!.enumerated() {
			let _ = UILabel().then { [unowned self] in
				$0.text = menuItem.name
				$0.backgroundColor = Colors.radiumGray
				$0.layer.borderWidth = 0.25
				$0.layer.borderColor = UIColor.gray.cgColor
				$0.tag = i
				
				let gesture = UITapGestureRecognizer()
				gesture.numberOfTapsRequired = 1
				gesture.addTarget(self, action: #selector(self.tappedItem(sender:)))
				$0.addGestureRecognizer(gesture)
				$0.isUserInteractionEnabled = true
				
				self.addSubview($0)
				$0.snp.makeConstraints { (make) in
					if i == 0 {
						make.top.equalTo(self)
					} else {
						make.top.equalTo(itemViews[i - 1].snp.bottom)
					}
					make.left.equalTo(self)
					make.width.equalTo(self)
					make.height.equalTo(SharedDropdownMenu.defaultMenuItemHeight)
				}
				
				itemViews.append($0)
			}
		}
	}
	
	func show(in view: UIView, from point: CGPoint) {
		let bounds = view.bounds
		let height = SharedDropdownMenu.defaultMenuItemHeight * CGFloat(menuItems!.count)
		let width = SharedDropdownMenu.defaultMenuWidth
		
		var x = point.x - (width / 2)
		if x + width > bounds.width - 8 {
			x = bounds.width - width - 8
		}
		if x < 8 {
			x = 8
		}
		
		self.frame = CGRect(x: x, y: point.y, width: width, height: height)
		view.addSubview(self)
	}
	
	func dismiss() {
		self.removeFromSuperview()
	}
	
	func tappedItem(sender: UIGestureRecognizer) {
		dismiss()
		guard let item = menuItems?[sender.view!.tag] else { return }
		item.action?()
	}

}
