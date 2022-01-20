//
//  DKFLLogFileListVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/4.
//

import UIKit

class DKFLLogFileListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var files: [DKLogFileInfo] = []
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKFLLogFileListVC", bundle: DebugKit.dk_bundle(name: "FileLogViewer"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKFLLogFileListVC", bundle: DebugKit.dk_bundle(name: "FileLogViewer"))
    }
    
    open override func viewDidLoad() {        
        setupViews()
        loadData()
        addObserver()
        
    }
    
    func setupViews() {
        tableView.tableFooterView = UIView()
    }
    
    func loadData() {
        files = DKFileManagerDefault().sortedLogFileInfos
        tableView.reloadData()
    }
    
    func addObserver() {
        // 监听文件创建
        NotificationCenter.default.addObserver(self, selector: #selector(notiCreatedLogFile(noti:)), name: .DKFLLogCreatedLogFile, object: nil)
    }
    
    // MARK: 文件创建监听
    @objc func notiCreatedLogFile(noti: Notification) {
        DispatchQueue.main.async {
            self.loadData()
        }
    }
}

extension DKFLLogFileListVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return files.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
        }
        
        let fileInfo = files[indexPath.item]
        
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel?.text = fileInfo.fileName.components(separatedBy: " ").last
        cell!.detailTextLabel?.text = fileInfo.description
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileInfo = files[indexPath.item]
        let logListVC = DKFLLogListVC(fileInfo: fileInfo)
        navigationController?.pushViewController(logListVC, animated: true)
    }
}


extension DKFLLogFileListVC: DKTool {
    static func configTool() {
        DebugKit.share.mediator.router.register(url: "dk://DKFLLogFileListVC") { params, success, fail in
            DebugKit.share.debugNavC?.pushViewController(DKFLLogFileListVC(), animated: true)
            success?(nil)
        }
        
        DebugKit.share.toolBox.add(name: "Log", summary: "查看本地记录的日志", priority: 501) { _ in
            DebugKit.share.mediator.router.open(url: "dk://DKFLLogFileListVC")
        }
    }
}
