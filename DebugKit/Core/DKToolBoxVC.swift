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
        super.init(nibName: "DKToolBoxVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKToolBoxVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    open override func viewDidLoad() {
        title = "DebugKit"
        
        setupViews()
        loadData()
    }
    
    func setupViews() {
        
    }
    
    func loadData() {
        tools.append([
            toolNameKey: "H5调试",
            toolSummaryKey: "提供跳转到包房内部WebView页面的方法",
            toolVCClassKey: "DebugKit.DKH5VC"
        ])
        
        tools.append([
            toolNameKey: "Log",
            toolSummaryKey: "查看本地记录的日志",
            toolVCClassKey: "DebugKit.DKFLLogFileListVC"
        ])
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true) {
            DebugKit.share.closeDebug()
        }   
    }
}

extension DKToolBoxVC: UITableViewDelegate, UITableViewDataSource {
    
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


