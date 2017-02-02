//
//  UIImageExtensions.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

extension UIImage {
	class func imageFrom(systemItem: UIBarButtonSystemItem) -> UIImage? {
		let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
		
		// add to toolbar and render it
		UIToolbar().setItems([tempItem], animated: false)
		
		// got image from real uibutton
        if let itemView = tempItem.value(forKey: "view") as? UIView {
            for view in itemView.subviews {
                if let button = view as? UIButton, let imageView = button.imageView {
                    return imageView.image
                }
            }
        }
		
		return nil
	}
	
	func makeThumbnailOfSize(size: CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		
		self.draw(in: CGRect(origin: .zero, size: size))
		let newThumbnail = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return newThumbnail!
	}
}
