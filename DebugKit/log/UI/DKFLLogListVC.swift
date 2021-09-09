//
//  DKFLLogListVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/4.
//

import UIKit

class DKFLLogListVC: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var fileInfo: DKLogFileInfo?
    var dateFomatter: DateFormatter?
    var logReader: DKFileReaderDefault?
    var logs: [DKLogMessage] = []
    var selectKeywords: [String] = []
    var keywords: [String] = []
    
    var filtrationLogs: [DKLogMessage] = []
    
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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(export))
        
        tableView.tableFooterView = UIView()
        
        keywordCollectionView.register(UINib(nibName: DKFLLogKeyWordCell.cellName,
                                              bundle: DebugKit.dk_bundle(name: "Log")),
                                        forCellWithReuseIdentifier: DKFLLogKeyWordCell.cellName)
    }
    
    func loadData() {
        guard let fileInfo = self.fileInfo else {
            return
        }
        
        logReader = DKFileReaderDefault(filePath: fileInfo.filePath)
        logReader?.logsDidUpdateCallback = { [weak self](logs, keywords) in
            self?.logs = logs
            self?.keywords = keywords.filter({ keyword in
                if let has = self?.selectKeywords.contains(keyword),
                   has {
                    return false
                } else {
                    return true
                }
            })
            self?.filter()
        }
    }
    
    func filter() {
        let keyword = selectKeywords.reduce("") { reuslt, keyword in
            reuslt + (reuslt.count > 0 ? "/" : "") + keyword
        }
        if keyword.count > 0 {
            filtrationLogs = logs.filter(keyword: keyword)
        } else {
            filtrationLogs = logs
        }
        
        if let message = self.searchBar.text,
           message.count > 0 {
            filtrationLogs = filtrationLogs.filter(message: message)
        }
        
        tableView.reloadSections([0], with: .automatic)
        keywordCollectionView.reloadData()
    }
    
    @objc func export() {
        if let filePath = fileInfo?.filePath {
            DebugKit.share(object: NSURL(fileURLWithPath: filePath),
                           fromVC: self)
        }
    }
    
}

extension DKFLLogListVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtrationLogs.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell!.accessoryType = .disclosureIndicator
        }
        
        let message = filtrationLogs[indexPath.item]
        
        var text = ""
        if let dateFomatter = self.dateFomatter {
            text.append( dateFomatter.string(from: message.date))
        }
        text.append("  \(message.keyword)")
        
        cell!.textLabel?.text = text
        cell!.detailTextLabel?.text = message.message.replacingOccurrences(of: " ", with: "")
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logMessage = filtrationLogs[indexPath.item]
        
        let jsonViewerVC = DKJsonViewerVC()
        jsonViewerVC.title = logMessage.keyword
        jsonViewerVC.jsonStr = logMessage.message
        navigationController?.pushViewController(jsonViewerVC, animated: true)
        
        searchBar.resignFirstResponder()
    }
}

extension DKFLLogListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return selectKeywords.count
        } else {
            return keywords.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DKFLLogKeyWordCell.cellName, for: indexPath) as! DKFLLogKeyWordCell
        
        if indexPath.section == 0, indexPath.item < selectKeywords.count {
            cell.title.text = selectKeywords[indexPath.row]
            cell.isSelected = true
        }
        
        if indexPath.section == 1 && indexPath.item < keywords.count {
            cell.title.text = keywords[indexPath.row]
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            cell.isSelected = true
        } else {
            cell.isSelected = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width:CGFloat = 0
        
        if indexPath.section == 0, indexPath.item < selectKeywords.count {
            width = DKFLLogKeyWordCell.cellH(keyword:selectKeywords[indexPath.row])
        } else if indexPath.section == 1 && indexPath.item < keywords.count {
            width = DKFLLogKeyWordCell.cellH(keyword:keywords[indexPath.row])
        }
        
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.item < keywords.count {
            selectKeywords.append(keywords.remove(at: indexPath.row))
        } else if indexPath.section == 0 && indexPath.item < selectKeywords.count {
            keywords.insert(selectKeywords.remove(at: indexPath.row), at: 0)
        }
        filter()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension DKFLLogListVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        filter()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filter()
    }
}
