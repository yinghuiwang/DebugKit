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
        
        let setIcon = UIImage(contentsOfFile: DebugKit.dk_bundle(name: "Core")?.path(forResource: "dk_icon_more@3x.png", ofType: nil) ?? "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: setIcon, style: .plain, target: self, action: #selector(moreClick))
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let userController = WKUserContentController()
        config.userContentController = userController
        webView = WKWebView(frame: .zero, configuration: config)
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
    
    @objc func export() {
        if let jsonStr = jsonStr {
            DebugKit.share(object: NSString(string: jsonStr.jsonFormatPrint()),
                           fromVC: self)
        }
    }
    
    @objc func moreClick() {
        let alert = UIAlertController(title: "更多", message: "操作菜单", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "分享", style: .default, handler: { [weak self] _ in
            self?.export()
        }))
        
        alert.addAction(UIAlertAction(title: "模拟发送", style: .default, handler: { [weak self] _ in
            DebugKit.share.mediator.router.open(url: "dk://DKMsgSimulation", params: ["bodyJson": (self?.jsonStr?.jsonFormatPrint() ?? "")])
        }))
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
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


extension DKJsonViewerVC: DKTool {
    static func configTool() {
        DebugKit.share.mediator.router.register(url: "dk://DKJsonViewerVC") { params, success, fail in
            let jsonViewerVC = DKJsonViewerVC()
            if let json = params?["json"] as? String {
                jsonViewerVC.jsonStr = json
            }
            DebugKit.share.debugNavC?.pushViewController(DKJsonViewerVC(), animated: true)
            success?(nil)
        }
    }
}
