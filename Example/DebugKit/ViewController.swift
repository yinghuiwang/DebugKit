//
//  ViewController.swift
//  DebugKit
//
//  Created by iyinghui@163.com on 08/30/2021.
//  Copyright (c) 2021 iyinghui@163.com. All rights reserved.
//

import UIKit
import DebugKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var tools: [[String: String]] = []
    let toolNameKey = "toolNameKey"
    let toolSummaryKey = "toolSummaryKey"
    let toolVCClassKey = "toolVCClassKey"
    
    open override func viewDidLoad() {
        title = "DebugKitExample"
        
        setupViews()
        loadData()
        
        DebugKit.share.setup()
        DebugKit.share.enableConsoleLog = true
        
        
        DebugKit.share.actionHandle = { (key, value) in
            print("actionHandle:{ \(key): \(value) }")
        }
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
