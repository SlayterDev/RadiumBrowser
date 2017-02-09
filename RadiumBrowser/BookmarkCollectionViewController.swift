//
//  BookmarkCollectionViewController.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 2/8/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

private let reuseIdentifier = "Cell"

class BookmarkCollectionViewController: UICollectionViewController {
	
	var notificationToken: NotificationToken!
	var realm: Realm!
	
	var bookmarks: Results<Bookmark>?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "Bookmarks"
		
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
		
		self.collectionView?.backgroundColor = .white
		self.collectionView?.contentInset = UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 8)
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))

        // Register cell classes
        self.collectionView!.register(BookmarkCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

		do {
			realm = try Realm()
			bookmarks = realm.objects(Bookmark.self)
			notificationToken = bookmarks?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
				guard let collectionView = self?.collectionView else { return }
				switch changes {
				case .initial:
					collectionView.reloadData()
				case .update(_, _, _, _):
					collectionView.reloadSections([0])
				case .error(let error):
					logRealmError(error: error)
				}
			}
		} catch let error {
			logRealmError(error: error)
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	func done() {
		self.dismiss(animated: true, completion: nil)
	}
	
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bookmarks?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? BookmarkCollectionViewCell
		
		let bookmark = bookmarks?[indexPath.row]
		cell?.textLabel?.text = bookmark?.name
		if let imgURL = URL(string: bookmark!.iconURL) {
			cell?.imageView?.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "globe"))
		}
		
        return cell!
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

}
