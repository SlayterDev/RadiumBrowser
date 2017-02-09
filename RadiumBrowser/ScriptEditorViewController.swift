//
//  ScriptEditorViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/2/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift
import Highlightr

protocol ScriptEditorDelegate: class {
	func addScript(named name: String?, source: String?, injectionTime: Int)
}

class ScriptEditorViewController: UIViewController, UITextViewDelegate {
	
	var textView: UITextView?
	var injectionTimeSelector: UISegmentedControl?
	var scriptName: String?
	
	var prevModel: ExtensionModel?
	
	weak var delegate: ScriptEditorDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.prompt = scriptName
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.done(sender:)))
		
        let textStorage = CodeAttributedString()
        textStorage.language = "JavaScript"
        textStorage.highlightr.setTheme(to: "monokai-sublime")
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        let textContainer = NSTextContainer(size: view.bounds.size)
        layoutManager.addTextContainer(textContainer)
        
        textView = UITextView(frame: .zero, textContainer: textContainer).then { [unowned self] in
			$0.autocorrectionType = .no
			$0.autocapitalizationType = .none
			$0.font = UIFont(name: "Menlo-Regular", size: UIFont.systemFontSize + 3)
            $0.inputAccessoryView = DoneAccessoryView(targetView: $0, width: self.view.frame.width)
            $0.backgroundColor = textStorage.highlightr.theme.themeBackgroundColor
            $0.delegate = self
			
			if let prevModel = self.prevModel {
				$0.text = prevModel.source
			}
			
			self.view.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.edges.equalTo(self.view)
			}
		}
		
		injectionTimeSelector = UISegmentedControl(items: ["At Start", "At End"]).then { [unowned self] in
			$0.sizeToFit()
			
			if let prevModel = self.prevModel {
				$0.selectedSegmentIndex = prevModel.injectionTime
			} else {
				$0.selectedSegmentIndex = 1
			}
			self.navigationItem.titleView = $0
		}
		
		let notificationCenter = NotificationCenter.default
		notificationCenter.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
		                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		notificationCenter.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
		                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
		notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Saving

	func done(sender: UIBarButtonItem) {
		saveChanges()
		let _ = self.navigationController?.popViewController(animated: true)
	}
	
    func saveChanges() {
        if let model = prevModel {
            do {
                let realm = try Realm()
                try realm.write {
                    model.source = textView!.text
					model.injectionTime = injectionTimeSelector!.selectedSegmentIndex
                }
            } catch let error {
                logRealmError(error: error)
            }
        } else {
            delegate?.addScript(named: scriptName, source: textView?.text, injectionTime: injectionTimeSelector!.selectedSegmentIndex)
        }
    }
    
    // MARK: - Keyboard Methods
    
	func getTextViewInsets(keyboardHeight: CGFloat) -> CGFloat {
		// Calculate the offset of our tableView in the
		// coordinate space of of our window
		guard let window = (UIApplication.shared.delegate as? AppDelegate)?.window else { return 0 }
		let tableViewFrame = textView!.superview!.convert(textView!.frame, to: window)
		
		// BottomInset = part of keyboard that is covering the tableView
		let bottomInset = keyboardHeight - (window.frame.height - tableViewFrame.height - tableViewFrame.origin.y)
		
		// Return the new insets + update this if you have custom insets
		return bottomInset -
			   CGFloat((UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeLeft) ?
			   44 :
			   0)
	}
    
	func keyboardWillShow(notification: NSNotification) {
		let userInfo = notification.userInfo!
		guard let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else { return }
        
		if isiPadUI {
			textView?.snp.remakeConstraints { (make) in
				make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: 0,
				                                                 bottom: getTextViewInsets(keyboardHeight: keyboardHeight),
				                                                 right: 0))
			}
		} else {
			textView?.snp.remakeConstraints { (make) in
				make.edges.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeight, right: 0))
			}
		}
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		textView?.snp.remakeConstraints { (make) in
			make.edges.equalTo(self.view)
		}
		
		UIView.animate(withDuration: 0.3) {
			self.view.layoutIfNeeded()
		}
	}
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" else { return true }
        
        let end = textView.text.index(textView.text.startIndex, offsetBy: range.location)
        guard let prevLine = textView.text.substring(with: textView.text.startIndex..<end).lines.last else { return true }
        
        var nextLevel = 0
        if prevLine.characters.last == "{" {
            nextLevel = 1
        }
        
        let indentationLevel = prevLine.getIndentationLevel() + nextLevel
        let paddingString = "    " * indentationLevel
        
        if range.location == textView.text.characters.count {
            let updatedText = "\n" + paddingString
            textView.text = textView.text + updatedText
        } else {
            let beginning = textView.beginningOfDocument
            let start = textView.position(from: beginning, offset: range.location)
            let rangeEnd = textView.position(from: start!, offset: range.length)
            let textRange = textView.textRange(from: start!, to: rangeEnd!)
            
            textView.replace(textRange!, withText: "\n" + paddingString)
            
            let cursor = NSRange(location: range.location + "\n\(paddingString)".characters.count, length: 0)
            textView.selectedRange = cursor
        }
        
        return false
    }
	
}
