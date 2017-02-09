//
//  AddBookmarkTableViewController.swift
//  RadiumBrowser
//
//  Created by bslayter on 2/9/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import RealmSwift

fileprivate let reuseidentifier = "bookmarkCell"

class AddBookmarkTableViewController: UITableViewController {
    
    var pageIconURL: String?
    var pageTitle: String?
    var pageURL: String?
    
    var titleTextField: UITextField?
    var urlTextField: UITextField?
    
    override var preferredContentSize: CGSize {
        get {
            return CGSize(width: 414, height: 200)
        }
        set { super.preferredContentSize = newValue }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Add Bookmark"
        
        self.navigationController?.navigationBar.barTintColor = Colors.radiumGray
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(done))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))

        tableView.register(BookmarkTableViewCell.self, forCellReuseIdentifier: reuseidentifier)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displayValidationError(for field: String) {
        let av = UIAlertController(title: "Error", message: "Please enter a \(field) for your bookmark.", preferredStyle: .alert)
        av.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        self.present(av, animated: true, completion: nil)
    }
    
    func done() {
        guard let title = titleTextField?.text, title != "" else {
            displayValidationError(for: "title")
            return
        }
        guard let url = urlTextField?.text, url != "" else {
            displayValidationError(for: "URL")
            return
        }
        
        let bookmark = Bookmark(value: ["id": UUID().uuidString, "name": title,
                                        "pageURL": url, "iconURL": pageIconURL ?? ""])
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(bookmark)
            }
        } catch let error {
            logRealmError(error: error)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseidentifier, for: indexPath) as? BookmarkTableViewCell

        if let pageIconURL = pageIconURL, let imgURL = URL(string: pageIconURL) {
            cell?.imageView?.sd_setImage(with: imgURL, placeholderImage: UIImage(named: "globe"))
        } else {
            cell?.imageView?.image = UIImage(named: "globe")
        }
        
        titleTextField = cell?.titleTextField
        urlTextField = cell?.urlTextField
        
        cell?.titleTextField?.text = pageTitle
        cell?.urlTextField?.text = pageURL

        return cell!
    }

}
