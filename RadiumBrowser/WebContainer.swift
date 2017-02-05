//
//  WebContainer.swift
//  RadiumBrowser
//
//  Created by Bradley Slayter on 1/31/17.
//  Copyright © 2017 bslayter. All rights reserved.
//

import UIKit
import WebKit
import RealmSwift

class WebContainer: UIView, WKNavigationDelegate, WKUIDelegate {
	
	weak var parentView: UIView?
	var webView: WKWebView?
    var isObserving = false
	
	weak var tabView: TabView?
	
	var progressView: UIProgressView?
    
    var notificationToken: NotificationToken!
	
	deinit {
        if isObserving {
            webView?.removeObserver(self, forKeyPath: "estimatedProgress")
        }
        notificationToken.stop()
	}
	
	init(parent: UIView) {
		super.init(frame: .zero)
		
		self.parentView = parent
		
		webView = WKWebView(frame: .zero, configuration: loadConfiguration()).then { [unowned self] in
			$0.allowsLinkPreview = true
			$0.allowsBackForwardNavigationGestures = true
			$0.navigationDelegate = self
            $0.uiDelegate = self
			
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
        
        do {
            let realm = try Realm()
            self.notificationToken = realm.addNotificationBlock { notification, realm in
                self.reloadExtensions()
            }
        } catch let error as NSError {
            print("Error occured opening realm: \(error.localizedDescription)")
        }
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
    // MARK: - Configuration Setup
    
	func loadConfiguration() -> WKWebViewConfiguration {
		let config = WKWebViewConfiguration()
		
		let contentController = WKUserContentController()
		let _ = loadExtensions().map {
			contentController.addUserScript($0)
		}
		
		config.userContentController = contentController
		config.processPool = WebViewManager.sharedProcessPool
		
		return config
	}
	
	func loadExtensions() -> [WKUserScript] {
		var extensions = [WKUserScript]()
		
		var models: Results<ExtensionModel>?
		do {
			let realm = try Realm()
			models = realm.objects(ExtensionModel.self)
		} catch let error {
			print("Could not load extensions: \(error.localizedDescription)")
			return []
		}
		
		for model in models! {
            guard model.active else { continue }
			let injectionTime: WKUserScriptInjectionTime = (model.injectionTime == 0) ? .atDocumentStart : .atDocumentEnd
			let script = WKUserScript(source: model.source, injectionTime: injectionTime, forMainFrameOnly: false)
			extensions.append(script)
		}
		
		return extensions
	}
    
    func reloadExtensions() {
        // Called when a new extension is added to Realm
        webView?.configuration.userContentController.removeAllUserScripts()
        let _ = loadExtensions().map {
            webView?.configuration.userContentController.addUserScript($0)
        }
    }
	
    // MARK: - View Managment
    
	func addToView() {
		guard let _ = parentView else { return }
		
		parentView?.addSubview(self)
		self.snp.makeConstraints { (make) in
			make.edges.equalTo(parentView!)
		}
		
		if !isObserving {
			webView?.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
			isObserving = true
		}
	}
	
	func removeFromView() {
		guard let _ = parentView else { return }
		
		// Remove ourself as the observer
        if isObserving {
            webView?.removeObserver(self, forKeyPath: "estimatedProgress")
            isObserving = false
            progressView?.setProgress(0, animated: false)
            progressView?.isHidden = true
        }
		
		self.removeFromSuperview()
	}
	
	func loadQuery(string: String) {
		var urlString = string
		if !urlString.isURL() {
			let searchTerms = urlString.replacingOccurrences(of: " ", with: "+")
			urlString = "http://google.com/search?q=" + searchTerms
		} else if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
			urlString = "http://" + urlString
		}
		
		if let url = URL(string: urlString) {
			let _ = webView?.load(URLRequest(url: url))
		}
	}
	
    // MARK: - Webview Delegate
    
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if keyPath == "estimatedProgress" {
			progressView?.isHidden = webView?.estimatedProgress == 1
			progressView?.setProgress(Float(webView!.estimatedProgress), animated: true)
            
            if webView?.estimatedProgress == 1 {
                progressView?.setProgress(0, animated: false)
            }
		}
	}
    
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		WebViewManager.shared.logPageVisit(url: webView.url?.absoluteString, pageTitle: webView.title)
		
		tabView?.tabTitle = webView.title
		
		if let tabContainer = tabView?.superview as? TabContainerView, isObserving {
			let attrUrl = WebViewManager.shared.getColoredURL(url: webView.url)
			if attrUrl.string == "" {
				tabContainer.addressBar?.setAddressText(webView.url?.absoluteString)
			} else {
				tabContainer.addressBar?.setAttributedAddressText(attrUrl)
			}
			tabContainer.updateNavButtons()
		}
	}
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let tabContainer = tabView?.superview as? TabContainerView, navigationAction.targetFrame == nil {
            tabContainer.addNewTab(withRequest: navigationAction.request)
        }
        return nil
    }
	
	// MARK: - Alert Methods
	
	func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
	             initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
		let av = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
		av.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
			completionHandler()
		}))
		self.parentViewController?.present(av, animated: true, completion: nil)
	}
	
	func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
	             initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
		let av = UIAlertController(title: webView.title, message: message, preferredStyle: .alert)
		av.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
			completionHandler(true)
		}))
		av.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
			completionHandler(false)
		}))
		self.parentViewController?.present(av, animated: true, completion: nil)
	}
	
	func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
	             defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
		let av = UIAlertController(title: webView.title, message: prompt, preferredStyle: .alert)
		av.addTextField(configurationHandler: { (textField) in
			textField.placeholder = prompt
			textField.text = defaultText
		})
		av.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(action) in
			completionHandler(av.textFields?.first?.text)
		}))
		av.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(action) in
			completionHandler(nil)
		}))
		self.parentViewController?.present(av, animated: true, completion: nil)
	}
}
