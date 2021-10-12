//
//  DKFLLogListVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/4.
//

import UIKit

class DKFLLogListVC: UIViewController {

    let searchBar = UISearchBar()
    @IBOutlet weak var keywordCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    var fileInfo: DKLogFileInfo?
    var dateFomatter: DateFormatter?
    var logReader: DKFileReaderDefault?
    var logs: [DKLogMessage] = []
    var keywordsGroup: [[String]] = []
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKFLLogListVC", bundle: DebugKit.dk_bundle(name: "FileLogViewer"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKFLLogListVC", bundle: DebugKit.dk_bundle(name: "FileLogViewer"))
    }
    
    convenience init(fileInfo: DKLogFileInfo?) {
        self.init(nibName: nil, bundle: nil)
        self.fileInfo = fileInfo
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss:SSS"
        self.dateFomatter = dateFormatter
    }
    
    open override func viewDidLoad() {        
        setupViews()
        loadData()
    }
    
    func setupViews() {
        
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        searchBar.placeholder = "message"
        navigationItem.titleView = searchBar
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(export))
        
        tableView.tableFooterView = UIView()
        
        keywordCollectionView.register(UINib(nibName: DKFLLogKeyWordCell.cellName,
                                              bundle: DebugKit.dk_bundle(name: "FileLogViewer")),
                                        forCellWithReuseIdentifier: DKFLLogKeyWordCell.cellName)
    }
    
    func loadData() {
        guard let fileInfo = self.fileInfo else {
            return
        }
        
        if logReader == nil {
            logReader = DKFileReaderDefault(filePath: fileInfo.filePath)
            logReader?.logsDidUpdateCallback = { [weak self](logs, keywords) in
                self?.logs = logs
                self?.keywordsGroup = keywords
                
                self?.tableView.reloadSections([0], with: .automatic)
                self?.keywordCollectionView.reloadData()
            }
        }
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
        return logs.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 14)
            cell!.accessoryType = .disclosureIndicator
        }
        
        let message = logs[indexPath.item]
        
        var text = ""
        if let dateFomatter = self.dateFomatter {
            text.append( dateFomatter.string(from: message.date))
        }
        text.append("  \(message.keyword)")
        
        cell!.textLabel?.text = text
        if let summary = message.summary, summary.count > 0 {
            cell!.detailTextLabel?.text = summary
        } else {
            cell!.detailTextLabel?.text = message.message.replacingOccurrences(of: " ", with: "")
        }
        
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let logMessage = logs[indexPath.item]
        
        let jsonViewerVC = DKJsonViewerVC()
        jsonViewerVC.title = logMessage.keyword
        jsonViewerVC.jsonStr = logMessage.message
        navigationController?.pushViewController(jsonViewerVC, animated: true)
        
        searchBar.resignFirstResponder()
    }
}

extension DKFLLogListVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return keywordsGroup.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return keywordsGroup[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DKFLLogKeyWordCell.cellName, for: indexPath) as! DKFLLogKeyWordCell
        
        let keywords = keywordsGroup[indexPath.section]
        let keyword = keywords[indexPath.item]
        cell.title.text = keyword
        
        cell.longPressCallback = { [weak self] in
            self?.logReader?.addRejectKeyword(keyword: keyword)
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let keywordCell = cell as? DKFLLogKeyWordCell else {
            return
        }
        
        if indexPath.section == 0 {
            keywordCell.setType(type: .reject)
        } else if indexPath.section == 1 {
            keywordCell.setType(type: .select)
        } else if indexPath.section == 2 {
            keywordCell.setType(type: .normal)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let keywords = keywordsGroup[indexPath.section]
        let keyword = keywords[indexPath.item]
        let width = DKFLLogKeyWordCell.cellW(keyword: keyword)
        
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let keywords = keywordsGroup[indexPath.section]
        let keyword = keywords[indexPath.item]
        if indexPath.section == 0 {
            logReader?.removeRejectKeyword(keyword: keyword)
        } else if indexPath.section == 1 {
            logReader?.removeOnlyKeyword(keyword: keyword)
        } else if indexPath.section == 2 {
            logReader?.addOnlyKeyword(keyword: keyword)
        }
        
        searchBar.resignFirstResponder()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension DKFLLogListVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        logReader?.updateSearch(text: searchBar.text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        logReader?.updateSearch(text: searchBar.text)
    }
}
