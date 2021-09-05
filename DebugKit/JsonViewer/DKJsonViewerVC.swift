//
//  DKJsonViewerVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/5.
//

import UIKit
import WebKit

class DKJsonViewerVC: UIViewController {
    
    private var webView: WKWebView?
    var jsonStr: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        loadData()
    }
}


extension DKJsonViewerVC {
    // MARK: - PrivateMethod
    func setupViews() {
        view.backgroundColor = UIColor.white
        
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
    }
    
    @objc func loadData() {
        guard let path = DebugKit.dk_bundle(name: "JsonViewer")?.path(forResource: "index", ofType: "html") else {
            return
        }
        
        let url = URL(fileURLWithPath: path)
        let baseUrl = url.deletingLastPathComponent()
        webView?.loadFileURL(url, allowingReadAccessTo: baseUrl)
    }
}

// MARK: - WKNavigationDelegate
extension DKJsonViewerVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DebugKit.log("JsonViewerVC: didStart")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DebugKit.log("JsonViewerVC: didFinish")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DebugKit.log("JsonViewerVC: didFail")
        let err = error as NSError
        if err.code == NSURLErrorCancelled {
            return
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {

        guard let urlStr = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        
        if urlStr.hasSuffix("JsonViewer.bundle/index.html") {
            decisionHandler(.allow)
            return
        }
        
        
        DebugKit.log("JsonViewerVC: \(urlStr)")
        
        if "dkjsonview://setvalue" == urlStr {
            execJavaScript()
        } else {
            let webVC = DKWebVC()
            webVC.urlStr = urlStr
            navigationController?.pushViewController(webVC, animated: true)
        }
        
        decisionHandler(.cancel)
    }
    
    func execJavaScript() {
        
        guard let jsonStr = self.jsonStr else {
            return
        }
        
        let javaScript = "window.renderJson(\(jsonStr))"
        
        webView?.evaluateJavaScript(javaScript, completionHandler: { result, error in
            DebugKit.log("JsonViewerVC: result: \(String(describing: result)) error: \(String(describing: error))")
        })
    }
    
}

// MARK: - WKUIDelegate
extension DKJsonViewerVC: WKUIDelegate {
    
}
