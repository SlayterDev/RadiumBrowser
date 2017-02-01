//
//  WebContainer.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import WebKit

class WebContainer: UIView, WKNavigationDelegate {
	
	weak var parentView: UIView?
	var webView: WKWebView?
	
	weak var tabView: TabView?
	
	var progressView: UIProgressView?
	
	deinit {
		webView?.removeObserver(self, forKeyPath: "estimatedProgress")
	}
	
	init(parent: UIView) {
		super.init(frame: .zero)
		
		self.parentView = parent
		
		webView = WKWebView().then { [unowned self] in
			$0.allowsLinkPreview = true
			$0.allowsBackForwardNavigationGestures = true
			$0.navigationDelegate = self
			
			self.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.edges.equalTo(self)
			}
		}
		
		progressView = UIProgressView().then { [unowned self] in
			$0.isHidden = true
			
			self.addSubview($0)
			$0.snp.makeConstraints { (make) in
				make.width.equalTo(self)
				make.top.equalTo(self)
				make.left.equalTo(self)
			}
		}
		
		let _ = webView?.load(URLRequest(url: URL(string: "https://google.com")!))
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func addToView() {
		guard let _ = parentView else { return }
		
		parentView?.addSubview(self)
		self.snp.makeConstraints { (make) in
			make.edges.equalTo(parentView!)
		}
		
		webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
	}
	
	func removeFromView() {
		guard let _ = parentView else { return }
		
		// Remove ourself as the observer
		webView?.removeObserver(self, forKeyPath: "estimatedProgress")
		
		self.removeFromSuperview()
	}
	
	func loadQuery(string: String) {
		var urlString = string
		if !urlString.isURL() {
			let searchTerms = urlString.replacingOccurrences(of: " ", with: "+")
			urlString = "http://google.com/search?q=" + searchTerms
		} else if !urlString.hasPrefix("http://") || !urlString.hasPrefix("https://") {
			urlString = "http://" + urlString
		}
		
		if let url = URL(string: urlString) {
			let _ = webView?.load(URLRequest(url: url))
		}
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if (keyPath == "estimatedProgress") {
			progressView?.isHidden = webView?.estimatedProgress == 1
			progressView?.setProgress(Float(webView!.estimatedProgress), animated: true)
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		tabView?.tabTitle = webView.title
		
		if let tabContainer = tabView?.superview as? TabContainerView {
			tabContainer.addressBar?.addressField?.text = webView.url?.absoluteString
			tabContainer.updateNavButtons()
		}
	}
}
