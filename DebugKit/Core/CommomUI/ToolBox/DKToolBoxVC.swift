//
//  DKToolBoxVC.swift
//  ktv
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

open class DKToolBoxVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var toolBox: DKToolBox?
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKToolBoxVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKToolBoxVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    convenience init(toolBox: DKToolBox) {
        self.init()
        self.toolBox = toolBox
    }
    
    deinit {
        DebugKit.log("DKToolBoxVC deinit")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    open override func viewDidLoad() {
        title = "DebugKit"
        
        setupViews()
        loadData()
    }
    
    func setupViews() {
    }
    
    func loadData() {
        tableView.reloadData()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true) {
            DebugKit.share.closeDebug()
        }   
    }
}

extension DKToolBoxVC {
    
}

extension DKToolBoxVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toolBox?.tools.count ?? 0;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
        }
        
        guard let tool = toolBox?.tools[indexPath.item] else {
            return cell!
        }
        
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel?.text = tool.name
        cell!.detailTextLabel?.text = tool.summay
        
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tool = toolBox?.tools[indexPath.item] else {
            return
        }

        if let toolVCName = tool.vcClassName,
           let ToolVCClass = NSClassFromString(toolVCName) as? UIViewController.Type {
            let toolVC = ToolVCClass.init()
            toolVC.title = tool.name
            navigationController?.pushViewController(toolVC, animated: true)
            return
        }
        
        if let clickHandle = tool.clickHandle {
            clickHandle(self)
            return
        }
    }
}

