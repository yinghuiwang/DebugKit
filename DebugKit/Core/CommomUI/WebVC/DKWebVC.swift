//
//  DKWebVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/31.
//

import UIKit
import WebKit

class DKWebVC: DKBaseVC {
    
    private var webView: WKWebView?
    
    @objc var urlStr: String?
    
    deinit {
        webView?.removeObserver(self, forKeyPath: "title")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadData()
    }
}


extension DKWebVC {
    // MARK: - PrivateMethod
    func setupViews() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let userController = WKUserContentController()
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
        webView?.backgroundColor = UIColor.clear
        webView?.navigationDelegate = self
        webView?.uiDelegate = self
        
        view.addSubview(webView!)
        webView?.translatesAutoresizingMaskIntoConstraints = false
        webView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        webView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        webView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        webView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        webView?.addObserver(self, forKeyPath: "title", options: .new, context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = change?[.newKey] as? String {
                self.title = title
            }
        }
    }
    
    @objc func loadData() {
        guard let urlStr = self.urlStr else { return }

        
        guard let url = URL(string: urlStr) else { return }
        
        let request = NSMutableURLRequest(url: url)
        request.cachePolicy = .reloadIgnoringCacheData
        webView?.load(request as URLRequest)
    }
}

// MARK: - WKNavigationDelegate
extension DKWebVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DebugKit.log("Web: didStart")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DebugKit.log("Web: didFinish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DebugKit.log("Web: didFail")
        let err = error as NSError
        if err.code == NSURLErrorCancelled {
            return
        }
    }
}

// MARK: - WKUIDelegate
extension DKWebVC: WKUIDelegate {
    
}
