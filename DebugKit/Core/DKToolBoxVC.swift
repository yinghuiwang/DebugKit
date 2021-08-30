//
//  DKToolBoxVC.swift
//  ktv
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

open class DKToolBoxVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tools: [[String: String]] = []
    let toolNameKey = "toolNameKey"
    let toolSummaryKey = "toolSummaryKey"
    let toolVCClassKey = "toolVCClassKey"
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let debugKitBundle = Bundle(path: Bundle(for: Self.self).path(forResource: "Core.bundle", ofType: nil) ?? "")
        super.init(nibName: "DKToolBoxVC", bundle: debugKitBundle)
    }
    
    public required init?(coder: NSCoder) {
        let debugKitBundle = Bundle(path: Bundle(for: Self.self).path(forResource: "Core.bundle", ofType: nil) ?? "")
        super.init(nibName: "DKToolBoxVC", bundle: debugKitBundle)
    }
    
    open override func viewDidLoad() {
        title = "DebugKit"
        
        setupViews()
        loadData()
    }
    
    func setupViews() {
        tableView.tableFooterView = UIView()
    }
    
    func loadData() {
        tools.append([
            toolNameKey: "H5调试",
            toolSummaryKey: "提供跳转到包房内部WebView页面的方法",
            toolVCClassKey: "DebugKit.DKH5VC"
        ])
    }
    
}

extension DKToolBoxVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tools.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(Self.self))
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


