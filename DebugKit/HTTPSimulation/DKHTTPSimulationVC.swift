//
//  DKMsgSimulationVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/30.
//

import UIKit

class DKHTTPSimulationVC: DKBaseVC {

    let nameTextField = UITextField()
    @IBOutlet weak var apiTV: UITextView!
    @IBOutlet weak var hostTF: UITextField!
    @IBOutlet weak var paramsTextView: UITextView!
    @IBOutlet weak var paramTVHConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var methodSC: UISegmentedControl!
    @IBOutlet weak var responseAraeView: UIView!
    @IBOutlet weak var responseAraeViewHConstraint: NSLayoutConstraint!
    
    var jsonVC: DKJsonViewerVC?
    let msgSimulation = DKHTTPSimulation()

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKHTTPSimulationVC", bundle: DebugKit.dk_bundle(name: "HTTPSimulation"))
    }

    public required init?(coder: NSCoder) {
        super.init(nibName: "DKHTTPSimulationVC", bundle: DebugKit.dk_bundle(name: "HTTPSimulation"))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        loadData()
    }

    func loadData() {
        msgSimulation.reload()
    }

    func setupViews() {
        nameTextField.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        nameTextField.returnKeyType = .done
        nameTextField.borderStyle = .roundedRect
        nameTextField.delegate = self
        nameTextField.placeholder = "name"
        nameTextField.clearButtonMode = .always

        navigationItem.titleView = nameTextField
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(openHistory))

        apiTV.delegate = self
        apiTV.returnKeyType = .done
        if let json = msgSimulation.originalJson {
            configContent(json: json)
        }

        sendBtn.layer.cornerRadius = 5
        sendBtn.layer.masksToBounds = true
        sendBtn.layer.borderWidth = 0.5
        sendBtn.layer.borderColor = UIColor.systemBlue.cgColor
        
        let jsonVC = DKJsonViewerVC()
        self.addChild(jsonVC)
        responseAraeView.addSubview(jsonVC.view)
        responseAraeView.autoresizesSubviews = false
        jsonVC.view.topAnchor.constraint(equalTo: responseAraeView.topAnchor).isActive = true
        jsonVC.view.bottomAnchor.constraint(equalTo: responseAraeView.bottomAnchor).isActive = true
        jsonVC.view.leftAnchor.constraint(equalTo: responseAraeView.leftAnchor).isActive = true
        jsonVC.view.rightAnchor.constraint(equalTo: responseAraeView.rightAnchor).isActive = true
        jsonVC.loadCompletedClosure = { [weak self] webView in
            self?.responseAraeViewHConstraint.constant = webView.scrollView.contentSize.height;
        }
        self.jsonVC = jsonVC
    }
    
    func configContent(json: String) {
        guard let request = json.toDictionary() else {
            return
        }
        
        if let method = request["method"] as? String {
            if method == "GET" {
                methodSC.selectedSegmentIndex = 0
            } else if method == "POST" {
                methodSC.selectedSegmentIndex = 1
            }
        }
        
        if let host = request["host"] as? String {
            hostTF.text = host
        }
        
        if let api = request["api"] as? String {
            nameTextField.text = api.components(separatedBy: ".").last
            apiTV.text = api
        }
        
        if let param = request["param"] as? [String: AnyObject] {
            paramsTextView.text = param.toJsonString()
            paramTVHConstraint.constant = paramsTextView.contentSize.height
        }
    }
    
    @objc func openHistory() {
        let histroyVC = DKHTTPRequestHistoryVC()
        histroyVC.msgSimulation = msgSimulation
        histroyVC.selecteMessage = { [weak self] message in
            guard let self = self else { return }
            if message.method == "GET" {
                self.methodSC.selectedSegmentIndex = 0
            } else if message.method == "POST" {
                self.methodSC.selectedSegmentIndex = 1
            }
            
            self.hostTF.text = message.host
            self.nameTextField.text = message.api.components(separatedBy: ".").last
            self.apiTV.text = message.api
            self.paramsTextView.text = message.param
        }
        self.present(histroyVC, animated: true)
    }

    @IBAction func sendToServer(_ sender: Any) {
        guard let requestName = nameTextField.text,
              let host = hostTF.text,
              let api = apiTV.text else {
            return
        }
        
        let method = methodSC.selectedSegmentIndex == 0 ? "GET": "POST"
        
        self.msgSimulation.send(key: requestName, method: method, host: host, api: api, param: paramsTextView.text) { [weak self] response in
            self?.jsonVC?.jsonStr = response
            self?.jsonVC?.loadData()
        }
    }


    @IBAction func cleanUrl(_ sender: Any) {
        apiTV.text = nil
    }
    
    @IBAction func cleanParams(_ sender: Any) {
        paramsTextView.text = nil
    }

    @IBAction func clickQRBtn(_ sender: Any) {
        let qrCodeVC = DKQRCodeVC()
        qrCodeVC.QRCodeCallback = { [weak self] result in
            self?.configContent(json: result)
        }
        let nav = UINavigationController(rootViewController: qrCodeVC)
        present(nav, animated: true, completion: nil)
    }
}

extension DKHTTPSimulationVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //判断输入的字是否是回车，即按下return
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension DKHTTPSimulationVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        apiTV.resignFirstResponder()
        paramsTextView.resignFirstResponder()
    }
}

extension DKHTTPSimulationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension DKHTTPSimulationVC: DKTool {
    static func configTool() {
        DebugKit.share.mediator.router.register(url: "dk://DKHTTPSimulationVC") { params, success, fail in

            let HTTPSimulationVC = DKHTTPSimulationVC()
            if let bodyJson = params?["bodyJson"] as? String {
                HTTPSimulationVC.msgSimulation.originalJson = bodyJson
            }

            DebugKit.share.debugNavC?.pushViewController(HTTPSimulationVC, animated: true)
            success?(nil)
        }

        DebugKit.share.toolBox.add(name: "HTTP发送", summary: "提供房间内HTTP模拟请求") { _ in
            DebugKit.share.mediator.router.open(url: "dk://DKHTTPSimulationVC")
        }
    }
}
