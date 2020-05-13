//
//  UIImageExtensions.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

extension UIImage {
	@objc class func imageFrom(systemItem: UIBarButtonItem.SystemItem) -> UIImage? {
		let tempItem = UIBarButtonItem(barButtonSystemItem: systemItem, target: nil, action: nil)
		
		// add to toolbar and render it
		let bar = UIToolbar()
        bar.setItems([tempItem], animated: false)
        bar.snapshotView(afterScreenUpdates: true)
		
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
	
	@objc func makeThumbnailOfSize(size: CGSize) -> UIImage {
		UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
		
		self.draw(in: CGRect(origin: .zero, size: size))
		let newThumbnail = UIGraphicsGetImageFromCurrentImageContext()
		
		UIGraphicsEndImageContext()
		
		return newThumbnail!
	}
}
