//
//  TabCollectionViewCell.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/7/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

protocol TabTrayCellDelegate: class {
    func didTapCloseBtn(tabCell: TabCollectionViewCell, tag: Int)
}

class TabCollectionViewCell: UICollectionViewCell {
    var screenshotView: UIImageView!
    var faviconView: UIImageView!
    var pageTitle: UILabel!
    
    var closeTabButton: UIButton!
    
    weak var delegate: TabTrayCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        screenshotView = UIImageView().then {
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
            
            self.contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.edges.equalTo(self.contentView)
            }
        }
        
        faviconView = UIImageView().then {
            $0.image = UIImage(named: "globe")
            $0.contentMode = .scaleAspectFit
            
            self.contentView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.width.equalTo(15)
                make.height.equalTo(15)
                make.left.equalTo(self.contentView).offset(8)
                make.bottom.equalTo(self.contentView).offset(-8)
            }
        }
        
        pageTitle = UILabel().then {
            self.contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.left.equalTo(faviconView.snp.right).offset(5)
                make.centerY.equalTo(faviconView)
                make.right.equalTo(self.contentView).offset(-8)
            }
        }
        
        closeTabButton = UIButton(type: .custom).then {
            $0.setTitle("Close", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.backgroundColor = UIColor.gray.withAlphaComponent(0.8)
            $0.layer.cornerRadius = 5
            $0.addTarget(self, action: #selector(tappedClose(sender:)), for: .touchUpInside)
            
            self.contentView.addSubview($0)
            $0.snp.makeConstraints { make in
                make.height.equalTo(25)
                make.top.right.equalTo(self.contentView).inset(8)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tappedClose(sender: UIButton) {
        delegate?.didTapCloseBtn(tabCell: self, tag: sender.tag)
    }
}
