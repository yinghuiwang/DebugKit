//
//  DKAppConfigVC.swift
//  ktv
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

open class DKAppConfigVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var appConfig = DkAppConfig.shared
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKAppConfigVC", bundle: DebugKit.dk_bundle(name: "AppConfig"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKAppConfigVC", bundle: DebugKit.dk_bundle(name: "AppConfig"))
    }
    
    convenience init(appConfig: DkAppConfig) {
        self.init()
        self.appConfig = appConfig
    }
    
    deinit {
        DebugKit.log("DKAppConfigVC deinit")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.tableView.reloadData()
    }
    
    open override func viewDidLoad() {
        title = "App 配置"
        
        setupViews()
        loadData()
    }
    
    func setupViews() {
       
    }
    
    func loadData() {
        self.tableView.reloadData()
    }
}

extension DKAppConfigVC {
    
}

extension DKAppConfigVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appConfig.items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
        }
        
        let item = appConfig.items[indexPath.item]
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel?.text = item.name
        cell!.detailTextLabel?.text = item.value
        if let value = UserDefaults.standard.string(forKey: item.key) {
            cell!.detailTextLabel?.text = value
        }
        
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = appConfig.items[indexPath.item]
        let configVC = DKTextConfigVC(item: item)
        navigationController?.pushViewController(configVC, animated: true)
    }
}


extension DKAppConfigVC: DKTool {
    static func configTool() {
        DebugKit.share.mediator.router.register(url: "dk://AppConfig") { params, success, fail in
            DebugKit.share.debugNavC?.pushViewController(DKAppConfigVC(), animated: true)
            success?(nil)
        }
        
        DebugKit.share.toolBox.add(name: "App 配置", summary: "提供 App 配置修改") { _ in
            DebugKit.share.mediator.router.open(url: "dk://AppConfig")
        }
    }
}
