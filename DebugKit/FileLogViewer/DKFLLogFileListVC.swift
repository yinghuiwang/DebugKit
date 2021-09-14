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
    }
    
    func setupViews() {
        tableView.tableFooterView = UIView()
    }
    
    func loadData() {
        files = DKFileManagerDefault().sortedLogFileInfos
        tableView.reloadData()
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

