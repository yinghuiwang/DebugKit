//
//  DKTBSetupVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/12/12.
//

import UIKit


struct DKTBSetupItem {
    let name: String
    let summay: String
    let clickHandle: (() -> Void)
}

open class DKTBSetupVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var items: [DKTBSetupItem] = []
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKTBSetupVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKTBSetupVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    deinit {
        DebugKit.log("DKTBSetupVC deinit")
    }
    
    open override func viewDidLoad() {
        title = "设置"
        
        setupViews()
        loadData()
    }
    
    func setupViews() {
    }
    
    func loadData() {
        
        items.append(DKTBSetupItem(name: "关闭DebugKit入口",
                                   summay: "仅仅关闭入口以及UI页面，后台任务不关闭，比如日志记录",
                                   clickHandle: { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: {
                DebugKit.share.closeDebug()
            })
        }))
        
        items.append(DKTBSetupItem(name: "关闭DebugKit",
                                   summay: "关闭入口、UI页面以及后台任务，比如日志记录",
                                   clickHandle: { [weak self] in
            self?.navigationController?.dismiss(animated: true, completion: {
                DebugKit.share.closeDebug()
            })
        }))
        
        
        tableView.reloadData()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true) {
            DebugKit.share.closeDebug()
        }
    }
}


extension DKTBSetupVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
        }
        
        let item = items[indexPath.item]
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel?.text = item.name
        cell!.detailTextLabel?.text = item.summay
        
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = items[indexPath.item]
        item.clickHandle()
    }
}

