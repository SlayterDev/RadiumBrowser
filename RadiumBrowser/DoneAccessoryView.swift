//
//  DoneAccessoryView.swift
//  DuctTape
//
//  Created by Brad Slayter on 2/6/17.
//  Copyright © 2017 Brad Slayter. All rights reserved.
//

import UIKit

class DoneAccessoryView: UIView {
    
    @objc var doneButton: UIButton?
    @objc var targetView: UIView?
    
    @objc init(targetView: UIView?, width: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: 35))
        
        self.targetView = targetView
        
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.25
        
        doneButtonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc func doneButtonSetup() {
        self.backgroundColor = Colors.radiumGray
        doneButton = UIButton(type: .custom).then {
            $0.setTitle("Done", for: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
            
            self.addSubview($0)
            $0.snp.makeConstraints { (make) -> Void in
                make.top.equalTo(self)
                if #available(iOS 11.0, *) {
                    make.right.equalTo(self.safeAreaLayoutGuide.snp.right).offset(-8)
                } else {
                    make.right.equalTo(self).offset(-8)
                }
                make.bottom.equalTo(self)
                make.width.equalTo(50.0)
            }
        }
    }
    
    @objc func dismissKeyboard() {
        targetView?.endEditing(true)
    }

}
