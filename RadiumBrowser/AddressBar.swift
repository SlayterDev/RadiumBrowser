//
//  AddressBar.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class AddressBar: UIView, UITextFieldDelegate {
    
    @objc static let standardHeight: CGFloat = 44
	
	@objc var backButton: UIButton?
	@objc var forwardButton: UIButton?
	@objc var refreshButton: UIButton?
    @objc var addressField: UITextField?
	@objc var menuButton: UIButton?
	
	@objc weak var tabContainer: TabContainerView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = Colors.radiumGray
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 0.5
		
		backButton = UIButton().then { [unowned self] in
            $0.setImage(UIImage(named: "back")?.withRenderingMode(.alwaysTemplate), for: .normal)
			$0.setTitleColor(.black, for: .normal)
			$0.setTitleColor(.lightGray, for: .disabled)
            $0.tintColor = .lightGray
			$0.isEnabled = false
			
			self.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.left.equalTo(self).offset(8)
				make.width.equalTo(32)
				make.centerY.equalTo(self)
			}
		}
		
		if isiPadUI {
			forwardButton = UIButton().then { [unowned self] in
                $0.setImage(UIImage(named: "forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
				$0.setTitleColor(.black, for: .normal)
				$0.setTitleColor(.lightGray, for: .disabled)
				$0.isEnabled = false
                $0.tintColor = .lightGray
				
				self.addSubview($0)
				$0.snp.makeConstraints { (make) in
					make.left.equalTo(self.backButton!.snp.right).offset(8)
					make.width.equalTo(32)
					make.centerY.equalTo(self)
				}
			}
		}
		
		menuButton = UIButton().then { [unowned self] in
			$0.setImage(UIImage(named: "menu"), for: .normal)
			
			self.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.width.equalTo(25)
				make.height.equalTo(25)
				make.centerY.equalTo(self)
				make.right.equalTo(self).offset(-8)
			}
		}
		
        addressField = SharedTextField().then { [unowned self] in
            $0.placeholder = "Address"
            $0.backgroundColor = .white
            $0.layer.borderColor = UIColor.lightGray.cgColor
            $0.layer.borderWidth = 0.5
            $0.layer.cornerRadius = 4
            $0.inset = 8
            
            $0.autocorrectionType = .no
            $0.autocapitalizationType = .none
            $0.keyboardType = .webSearch
			$0.delegate = self
			$0.clearButtonMode = .whileEditing
            
            $0.inputAccessoryView = DoneAccessoryView(targetView: $0, width: UIScreen.main.bounds.width).then { obj in
                obj.doneButton?.setTitle("Cancel", for: .normal)
                obj.doneButton?.snp.updateConstraints { make in
                    make.width.equalTo(60)
                }
            }
            
            self.addSubview($0)
            $0.snp.makeConstraints { (make) in
				if isiPadUI {
					make.left.equalTo(self.forwardButton!.snp.right).offset(8)
				} else {
					make.left.equalTo(self.backButton!.snp.right).offset(8)
				}
				make.top.equalTo(self).offset(8)
				make.bottom.equalTo(self).offset(-8)
				make.right.equalTo(self.menuButton!.snp.left).offset(-8)
            }
        }
		
		refreshButton = UIButton(frame: CGRect(x: -5, y: 0, width: 12.5, height: 15)).then {
			$0.setImage(UIImage.imageFrom(systemItem: .refresh)?.withRenderingMode(.alwaysTemplate), for: .normal)
			$0.tintColor = .gray
			addressField?.rightView = $0
			addressField?.rightViewMode = .unlessEditing
		}
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    @objc func setupNaviagtionActions(forTabConatiner tabContainer: TabContainerView) {
        backButton?.addTarget(tabContainer, action: #selector(tabContainer.goBack(sender:)), for: .touchUpInside)
        forwardButton?.addTarget(tabContainer, action: #selector(tabContainer.goForward(sender:)), for: .touchUpInside)
        refreshButton?.addTarget(tabContainer, action: #selector(tabContainer.refresh(sender:)), for: .touchUpInside)
    }
	
	// MARK: - Actions
	
	@objc func setAddressText(_ text: String?) {
		guard let _ = addressField else { return }
		
		if !addressField!.isFirstResponder {
			addressField?.text = text
            checkForLocalhost()
		}
	}
	
	@objc func setAttributedAddressText(_ text: NSAttributedString) {
		guard let _ = addressField else { return }
		
		if !addressField!.isFirstResponder {
			addressField?.attributedText = text
            checkForLocalhost()
		}
	}
    
    func checkForLocalhost() {
        if let address = addressField?.text, address.contains("localhost") {
            addressField?.text = ""
        }
    }
    
    // MARK: - Textfield Delegate
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		tabContainer?.loadQuery(string: textField.text)
		textField.resignFirstResponder()
		return true
	}
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
		if let string = textField.attributedText?.mutableCopy() as? NSMutableAttributedString {
			string.setAttributes([:], range: NSRange(0..<string.length))
			textField.attributedText = string
		}
        textField.selectAll(nil)
    }

}
