//
//  TabTrayViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 11/7/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import Crashlytics

class TabTrayViewController: UIViewController {
    
    static let identifier = "TabTrayIdentifier"
    
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Answers.logContentView(withName: "View Tab Tray", contentType: nil, contentId: nil, customAttributes: nil)
        
        view.backgroundColor = Colors.radiumUnselected
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.4)
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout).then {
            $0.dataSource = self
            $0.delegate = self
            $0.backgroundColor = Colors.radiumUnselected
            
            self.view.addSubview($0)
            $0.snp.makeConstraints { make in
                if #available(iOS 11.0, *) {
                    make.edges.equalTo(self.view.safeAreaLayoutGuide)
                } else {
                    make.edges.equalTo(self.view)
                }
            }
        }
        
        collectionView.register(TabCollectionViewCell.self, forCellWithReuseIdentifier: TabTrayViewController.identifier)
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension TabTrayViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TabContainerView.currentInstance?.tabList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TabTrayViewController.identifier, for: indexPath) as? TabCollectionViewCell
        
        let tab = TabContainerView.currentInstance?.tabList[indexPath.item]
        
        cell?.screenshotView.image = tab?.webContainer?.currentScreenshot ?? #imageLiteral(resourceName: "globe")
        if let faviconURLString = tab?.webContainer?.favicon?.getPreferredURL(), let faviconURL = URL(string: faviconURLString) {
            cell?.faviconView.sd_setImage(with: faviconURL, placeholderImage: #imageLiteral(resourceName: "globe"))
        } else {
            cell?.faviconView.image = #imageLiteral(resourceName: "globe")
        }
        cell?.pageTitle.text = tab?.webContainer?.webView?.title
        
        cell?.closeTabButton.tag = indexPath.item
        cell?.delegate = self
        
        if tab == TabContainerView.currentInstance?.currentTab {
            cell?.layer.borderWidth = 2
            cell?.layer.borderColor = UIColor.black.cgColor
        } else {
            cell?.layer.borderColor = UIColor.clear.cgColor
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let tab = TabContainerView.currentInstance?.tabList[indexPath.item] else { return }
        
        TabContainerView.currentInstance?.didTap(tab: tab)
        self.dismiss(animated: true, completion: nil)
    }
}

extension TabTrayViewController: TabTrayCellDelegate {
    func didTapCloseBtn(tabCell: TabCollectionViewCell, tag: Int) {
        guard let tab = TabContainerView.currentInstance?.tabList[tag] else { return }
        
        if TabContainerView.currentInstance?.close(tab: tab) ?? false {
            collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: [IndexPath(item: tag, section: 0)])
            }, completion: { _ in
                self.collectionView.reloadItems(at: self.collectionView.indexPathsForVisibleItems)
            })
        }
    }
}
