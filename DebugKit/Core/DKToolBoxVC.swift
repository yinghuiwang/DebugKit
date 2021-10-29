//
//  DKToolBoxVC.swift
//  ktv
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

struct DKTool {
    let name: String
    let summay: String
    let vcClassName: String
    let clickHandle: ((UIViewController) -> Void)?
}

open class DKToolBoxVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tools: [DKTool] = []
    
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
        tools.append(DKTool(name: "Log",
                            summay: "查看本地记录的日志",
                            vcClassName: "DebugKit.DKFLLogFileListVC",
                            clickHandle: nil))
        
        tools.append(DKTool(name: "UserDefaults",
                            summay: "查看本地记录的日志",
                            vcClassName:  "DebugKit.DKUserDefaultsVC",
                            clickHandle: nil))
        
        tools.append(DKTool(name: "H5调试",
                            summay: "提供跳转到包房内部WebView页面的方法",
                            vcClassName: "DebugKit.DKH5VC",
                            clickHandle: nil))
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
        cell!.textLabel?.text = tool.name
        cell!.detailTextLabel?.text = tool.summay
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tool = tools[indexPath.item]
        let toolVCName = tool.vcClassName
        if let ToolVCClass = NSClassFromString(toolVCName) as? UIViewController.Type {
            let toolVC = ToolVCClass.init()
            toolVC.title = tool.name
            navigationController?.pushViewController(toolVC, animated: true)
        }
    }
}


