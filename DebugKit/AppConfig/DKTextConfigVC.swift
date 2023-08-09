//
//  DKH5VC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/30.
//

import UIKit

class DKTextConfigVC: DKBaseVC {

    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cleanBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var searchHistoricalsKey: String {
        if let item = item {
            return DkAppConfig.shared.searchHistoricalsKey(key: item.key)
        }
        return "DKTextSearchHistoricalsKey"
    }
    
    var searchHistoricals: [String] = [] {
        didSet {
            if searchHistoricals.count == 0 {
                tableView.tableFooterView = UIView()
            } else {
                tableView.tableFooterView = tableFooterView
            }
        }
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKTextConfigVC", bundle: DebugKit.dk_bundle(name: "AppConfig"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKTextConfigVC", bundle: DebugKit.dk_bundle(name: "AppConfig"))
    }
    
    var item: AppConfigItem!
    
    init(item: AppConfigItem) {
        self.item = item
        super.init(nibName: "DKTextConfigVC", bundle: DebugKit.dk_bundle(name: "AppConfig"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = item.name + "配置"
        
        setupViews()
        loadData()
    }
    
    func loadData() {
        if let dataArray = DebugKit.userDefault()?.array(forKey: searchHistoricalsKey) as? [String] {
            dataArray.forEach { searchHistoricals.append($0) }
        }
        
        insetHistoricals(text: item.value)
        
        tableView.reloadData()
        
        
    }
    
    func setupViews() {
        
        self.searchTextView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.isUserInteractionEnabled = false
        
        cleanBtn.layer.cornerRadius = 5
        cleanBtn.layer.masksToBounds = true
        cleanBtn.layer.borderWidth = 0.5
        cleanBtn.layer.borderColor = UIColor.systemBlue.cgColor
        
        doneBtn.layer.cornerRadius = 5
        doneBtn.layer.masksToBounds = true
        doneBtn.layer.borderWidth = 0.5
        doneBtn.layer.borderColor = UIColor.systemBlue.cgColor
        
    }
    
    @IBAction func clickScan(_ sender: UIButton) {
        searchTextView.text = nil
    }
    
    @IBAction func clickJump(_ sender: UIButton) {
        done()
    }
    
    func done() {
        guard let text = searchTextView.text, let item = item, !text.isEmpty else { return }
        
        if item.type == .int {
            UserDefaults.standard.set(Int(text), forKey: item.key)
        } else {
            UserDefaults.standard.set(text, forKey: item.key)
        }
        
        insetHistoricals(text: text)
        tableView.reloadData()
        
        DebugKit.showToast(text: "已修改，重启 App 后生效")
    }
    
    func insetHistoricals(text: String) {
        if !searchHistoricals.contains(text) {
            searchHistoricals.insert(text, at: 0)
            DebugKit.userDefault()?.set(searchHistoricals, forKey: searchHistoricalsKey)
        }
    }
    
    @objc func cleanCache() {
        searchHistoricals.removeAll()
        DebugKit.userDefault()?.setValue(nil, forKey: searchHistoricalsKey)
        tableView.reloadData()
    }
    
    // MARK: - Lazy
    lazy var tableFooterView: UIView = {
        let tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 44))
        let btn = UIButton(frame: tableFooterView.bounds)
        btn.addTarget(self, action: #selector(cleanCache), for: .touchUpInside)
        btn.setTitle("清除历史记录", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(UIColor.systemBlue.withAlphaComponent(0.8), for: .normal)
        tableFooterView.addSubview(btn)
        return tableFooterView
    }()
}

extension DKTextConfigVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //判断输入的字是否是回车，即按下return
            textView.resignFirstResponder()
            done()
            return false
        }
        return true
    }
}

extension DKTextConfigVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistoricals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(Self.self))
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 12)
        }
        
        if indexPath.item < searchHistoricals.count  {
            cell!.textLabel?.text = searchHistoricals[indexPath.item]
        }
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.item < searchHistoricals.count  {
            self.searchTextView.text = searchHistoricals[indexPath.item]
        }
        
    }
}
