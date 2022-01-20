//
//  DKInfoViewerVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/12/19.
//

import UIKit

struct DKInfoItem: Codable {
    let name: String
    let summay: String
}

open class DKInfoViewerVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var items: [DKInfoItem] = []
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKInfoViewerVC", bundle: DebugKit.dk_bundle(name: "InfoViewer"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKInfoViewerVC", bundle: DebugKit.dk_bundle(name: "InfoViewer"))
    }
    
    deinit {
        DebugKit.log("DKInfoViewerVC deinit")
    }
    
    open override func viewDidLoad() {
        title = "信息"
        
        setupViews()
        loadData()
    }
    
    func setupViews() {
    }
    
    func loadData() {
        DebugKit.share.mediator.router.requset(url: "dk://getInfo") { [weak self] responds in
            if let data = responds as? Data,
               let items = try? JSONDecoder().decode([DKInfoItem].self, from: data) {
                self?.items = items
            }
            self?.tableView.reloadData()
        } fail: { err in
            
        }
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true) {
            DebugKit.share.closeDebug()
        }
    }
}


extension DKInfoViewerVC: UITableViewDelegate, UITableViewDataSource {
    
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
        
    }
}


extension DKInfoViewerVC: DKTool {
    static func configTool() {
        DebugKit.share.mediator.router.register(url: "dk://DKInfoViewerVC") { params, success, fail in
            DebugKit.share.debugNavC?.pushViewController(DKInfoViewerVC(), animated: true)
            success?(nil)
        }
        
        DebugKit.share.toolBox.add(name: "App重要信息", summary: "经常关注的一些关键信息") { _ in
            DebugKit.share.mediator.router.open(url: "dk://DKInfoViewerVC")
        }
    }
}
