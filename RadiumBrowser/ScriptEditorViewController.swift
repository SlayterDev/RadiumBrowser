//
//  ScriptEditorViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/2/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

protocol ScriptEditorDelegate: class {
	func addScript(named name: String?, source: String?)
}

class ScriptEditorViewController: UIViewController {
	
	var textView: UITextView?
	var scriptName: String?
	
	var prevModel: ExtensionModel?
	
	weak var delegate: ScriptEditorDelegate?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        title = scriptName
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.done(sender:)))
		
		textView = UITextView().then { [unowned self] in
			$0.autocorrectionType = .no
			$0.autocapitalizationType = .none
			$0.font = UIFont(name: "SF Mono Regular", size: UIFont.systemFontSize)
			
			if let prevModel = self.prevModel {
				$0.text = prevModel.source
			}
			
			self.view.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.edges.equalTo(self.view)
			}
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func done(sender: UIBarButtonItem) {
		if let model = prevModel {
			do {
				let realm = try Realm()
				try realm.write {
					model.source = textView!.text
				}
			} catch let error {
				logRealmError(error: error)
			}
		} else {
			delegate?.addScript(named: scriptName, source: textView?.text)
		}
		let _ = self.navigationController?.popViewController(animated: true)
	}
	
}
