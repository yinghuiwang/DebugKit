//
//  ViewController.swift
//  DebugKit
//
//  Created by iyinghui@163.com on 08/30/2021.
//  Copyright (c) 2021 iyinghui@163.com. All rights reserved.
//

import UIKit
import DebugKit
import Alamofire

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var tools: [[String: String]] = []
    let toolNameKey = "toolNameKey"
    let toolSummaryKey = "toolSummaryKey"
    let toolVCClassKey = "toolVCClassKey"
    
    let sessionManager = NSURLSessionTransferSizeUnknown
    
    open override func viewDidLoad() {
        title = "DebugKitExample"
        
        setupViews()
        loadData()
        
        DebugKit.share.setup()
        DebugKit.share.enableConsoleLog = true
        
        DebugKit.share.mediator.router.register(url: "dk://getInfo") { params, success, fail in
            var items: [[String: String]] = []
            
            do {
                var item: [String: String] = [:]
                item["name"] = "关闭DebugKit入口"
                item["summay"] = "关闭入口、UI页面以及后台任务，比如日志记录"
                items.append(item)
            }
            
            do {
                var item: [String: String] = [:]
                item["name"] = "关闭DebugKit"
                item["summay"] = "关闭入口、UI页面以及后台任务，比如日志记录"
                items.append(item)
            }
            
            guard let json = try? JSONEncoder().encode(items) else {
                fail?(DKRouterError(code: 1, errStr: "数据格式失败"))
                return
            }
            success?(json)
        }
        
        DebugKit.share.mediator.router.register(url: "dk://KTVLRWebVC") { params, success, fail in
            if let urlStr = params?["url"] as? String {
                DebugKit.showToast(text: "显示Url: \(urlStr)")
                success?(nil)
            } else {
                fail?(DKRouterError(code: 0, errStr: "没有注册WebVC"))
            }
        }
        
        
        DebugKit.share.mediator.notinationCenter.add(observer: self, name: "发WS消息") { value in
            if let body = value as? String {
                print("notinationCenter \(body)")
            }
        }
        
        
        DebugKit.share.mediator.router.register(url: "dk://SendHttpToServer") { params, success, fail in
            guard let params = params,
                  let methodStr = params["method"] as? String,
                  let host = params["host"] as? String,
                  let api = params["api"] as? String else {
                return
            }
                        
//            params["param"] as? Encodable
            var method = HTTPMethod.get
            if methodStr == "POST" {
                method = .post
            }
            
            AF.request("\(host)\(api)",
                       method: method,
                       parameters: ["": ""]).response { response in
                if let data = response.data, let text = String(data: data, encoding: .utf8) {
                    debugPrint(text)
                    success?(text)
                }
            }
        }
        
        // MARK: - AppConfig
        let  configItem = AppConfigItem(
            name: "host",
            selectContent: "",
            value: "hwww",
            key: "host",
            type: .text
        )
        DkAppConfig.shared.add(item: configItem)
    }
    
    func setupViews() {
        tableView.tableFooterView = UIView()
    }
    
    func loadData() {
        tools.append([
            toolNameKey: "DebugKitTest",
            toolSummaryKey: "展示DebugKit的入口",
            toolVCClassKey: "DebugKit_Example.DKEntryTestVC"
        ])
        
        tools.append([
            toolNameKey: "DKLogTest",
            toolSummaryKey: "log测试",
            toolVCClassKey: "DebugKit_Example.DKLogTestVC"
        ])

        tools.append([
            toolNameKey: "UserDefaultsTest",
            toolSummaryKey: "UserDefaults测试",
            toolVCClassKey: "DebugKit_Example.DKUserDefaultsTestVC"
        ])
        
        tools.append([
            toolNameKey: "DKToastTest",
            toolSummaryKey: "DKToastTest测试",
            toolVCClassKey: "DebugKit_Example.DKToastTestVC"
        ])

    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tools.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
        }
        
        let tool = tools[indexPath.item]
        
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel?.text = tool[toolNameKey]
        cell!.detailTextLabel?.text = tool[toolSummaryKey]
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tool = tools[indexPath.item]
        guard let toolVCName = tool[toolVCClassKey] else { return }
        if let ToolVCClass = NSClassFromString(toolVCName) as? UIViewController.Type {
            let toolVC = ToolVCClass.init()
            toolVC.title = tool[toolNameKey]
            navigationController?.pushViewController(toolVC, animated: true)
        }
    }
}

extension String {
    func toDictionary() -> [String: AnyObject]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: [JSONSerialization.ReadingOptions.init(rawValue: 0)]) as? [String: AnyObject]
            } catch let error as NSError {
                debugPrint(error)
            }
        }
        return nil
    }
}
