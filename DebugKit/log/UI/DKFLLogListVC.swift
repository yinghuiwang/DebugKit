//
//  DKFLLogListVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/4.
//

import UIKit

class DKFLLogListVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var fileInfo: DKLogFileInfo?
    var dateFomatter: DateFormatter?
    var logs: [DKLogMessage] = []
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKFLLogListVC", bundle: DebugKit.dk_bundle(name: "Log"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKFLLogListVC", bundle: DebugKit.dk_bundle(name: "Log"))
    }
    
    convenience init(fileInfo: DKLogFileInfo?) {
        self.init(nibName: nil, bundle: nil)
        self.fileInfo = fileInfo
        
        let dateFormatter = DateFormatter()
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
        self.dateFomatter = dateFormatter
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
        guard let fileInfo = self.fileInfo else {
            return
        }
        
        DispatchQueue.global().async {
            let messages = DKFileReaderDefault().read(atPath: fileInfo.filePath)
            
            DispatchQueue.main.async {
                if let messages = messages {
                    self.logs = messages
                    self.tableView.reloadData()
                }
            }
        }
        
        
    }
    
}

extension DKFLLogListVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
        }
        
        let message = logs[indexPath.item]
        
        cell!.accessoryType = .disclosureIndicator
        
        var text = ""
        if let timeStr = message.timestamp.components(separatedBy: " ").last {
            text.append(timeStr)
        }
        text.append("  \(message.keyword)")
        
        cell!.textLabel?.text = text
        cell!.detailTextLabel?.text = message.message
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logMessage = logs[indexPath.item]
        
        let jsonViewerVC = DKJsonViewerVC()
        jsonViewerVC.title = logMessage.keyword
        jsonViewerVC.jsonStr = logMessage.message
        navigationController?.pushViewController(jsonViewerVC, animated: true)
    }
}
