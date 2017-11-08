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
	
	static func item(named name: String, action: (() -> ())?) -> MenuItem {
		var menuItem = MenuItem()
		menuItem.name = "  " + name
		menuItem.action = action
		return menuItem
	}
}

class SharedDropdownMenu: UIView, UIGestureRecognizerDelegate {
	
	@objc static let defaultMenuItemHeight: CGFloat = 44
	@objc static let defaultMenuWidth: CGFloat = 250
	
	var menuItems: [MenuItem]?
	
	@objc var dismissGesture: UITapGestureRecognizer?
    
    var displayOrigin: CGPoint?
	
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
	
	@objc func setupMenu() {
		var itemViews = [UIView]()
		for (i, menuItem) in menuItems!.enumerated() {
			let _ = UIButton().then { [unowned self] in
				$0.setTitle(menuItem.name, for: .normal)
				$0.setTitleColor(.black, for: .normal)
				$0.setTitleColor(.lightGray, for: .highlighted)
				$0.contentHorizontalAlignment = .left
				$0.backgroundColor = Colors.radiumGray
				$0.layer.borderWidth = 0.5
				$0.layer.borderColor = UIColor.gray.cgColor
				$0.tag = i
				
				$0.addTarget(self, action: #selector(self.tappedItem(sender:)), for: .touchUpInside)
				
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
	
	@objc func show(in view: UIView, from point: CGPoint) {
		let bounds = view.bounds
		let height = SharedDropdownMenu.defaultMenuItemHeight * CGFloat(menuItems!.count)
		let width = SharedDropdownMenu.defaultMenuWidth
        displayOrigin = point
		
		var x = point.x - (width / 2)
		if x + width > bounds.width - 8 {
			x = bounds.width - width - 8
		}
		if x < 8 {
			x = 8
		}
		
        let finalFrame = CGRect(x: x, y: point.y, width: width, height: height)
		self.frame = CGRect(origin: point, size: .zero)
		view.addSubview(self)
		
		dismissGesture = UITapGestureRecognizer()
        dismissGesture?.delegate = self
		dismissGesture?.numberOfTapsRequired = 1
		view.window?.addGestureRecognizer(dismissGesture!)
        
        UIView.animate(withDuration: 0.25) {
            self.frame = finalFrame
        }
	}
	
	@objc func dismiss() {
		if let _ = dismissGesture {
			self.window?.removeGestureRecognizer(dismissGesture!)
		}
        
        guard let displayOrigin = displayOrigin else {
            self.removeFromSuperview()
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(origin: displayOrigin, size: .zero)
        }) { _ in
            self.removeFromSuperview()
        }
	}
	
	@objc func tappedItem(sender: UIButton) {
		dismiss()
		guard let item = menuItems?[sender.tag] else { return }
		item.action?()
	}
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: nil)
        if !self.frame.contains(point) {
            self.dismiss()
            return false
        }
        return false
    }

}
