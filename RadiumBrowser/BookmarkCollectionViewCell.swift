//
//  BookmarkCollectionViewCell.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/8/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class BookmarkCollectionViewCell: UICollectionViewCell {
	@objc var textLabel: UILabel?
	@objc var imageView: UIImageView?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		imageView = UIImageView().then {
			$0.contentMode = .scaleAspectFit
			
			self.contentView.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.top.equalTo(self.contentView)
				make.left.equalTo(self.contentView)
				make.width.equalTo(65)
				make.height.equalTo(65)
				make.centerX.equalTo(self.contentView)
			}
		}
		
		textLabel = UILabel().then {
			$0.textAlignment = .center
			$0.adjustsFontSizeToFitWidth = true
			$0.lineBreakMode = .byTruncatingTail
			$0.minimumScaleFactor = 0.8
			$0.font = .systemFont(ofSize: 14)
			
			self.contentView.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.top.equalTo(imageView!.snp.bottom).offset(4)
				make.left.equalTo(self.contentView)
				make.width.equalTo(self.contentView)
				make.bottom.equalTo(self.contentView)
			}
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
