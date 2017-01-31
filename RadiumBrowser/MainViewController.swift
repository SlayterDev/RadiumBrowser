//
//  MainViewController.swift
//  RadiumBrowser
//
//  Created by bslayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .gray
        
        let padding = UIView().then { [unowned self] in
            $0.backgroundColor = Colors.radiumDarkGray
            
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.width.equalTo(self.view)
                make.height.equalTo(22)
                make.top.equalTo(self.view)
            }
        }
        
        let tabContainer = TabContainerView(frame: .zero).then { [unowned self] in
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(padding.snp.bottom)
                make.left.equalTo(self.view)
                make.width.equalTo(self.view)
                make.height.equalTo(TabContainerView.standardHeight)
            }
        }
        
        let _ = AddressBar(frame: .zero).then { [unowned self] in
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(tabContainer.snp.bottom)
                make.width.equalTo(self.view)
                make.height.equalTo(AddressBar.standardHeight)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
