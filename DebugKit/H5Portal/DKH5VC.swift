//
//  DKH5VC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/30.
//

import UIKit

class DKH5VC: DKBaseVC {

    @IBOutlet weak var searchTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var qrBtn: UIButton!
    @IBOutlet weak var jumpBtn: UIButton!
    @IBOutlet weak var jumpAreaBottomConstraint: NSLayoutConstraint!
    
    let searchHistoricalsKey = "DKSearchHistoricalsKey"
    
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
        super.init(nibName: "DKH5VC", bundle: DebugKit.dk_bundle(name: "H5Portal"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKH5VC", bundle: DebugKit.dk_bundle(name: "H5Portal"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        loadData()
    }
    
    func loadData() {
        if let dataArray = UserDefaults.standard.array(forKey: searchHistoricalsKey) as? [String] {
            dataArray.forEach { searchHistoricals.append($0) }
            tableView.reloadData()
        }
    }
    
    func setupViews() {
        
        self.searchTextView.delegate = self
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.isUserInteractionEnabled = false
        
        qrBtn.layer.cornerRadius = 5
        qrBtn.layer.masksToBounds = true
        qrBtn.layer.borderWidth = 0.5
        qrBtn.layer.borderColor = UIColor.systemBlue.cgColor
        
        jumpBtn.layer.cornerRadius = 5
        jumpBtn.layer.masksToBounds = true
        jumpBtn.layer.borderWidth = 0.5
        jumpBtn.layer.borderColor = UIColor.systemBlue.cgColor
        
    }
    
    @IBAction func clickScan(_ sender: UIButton) {
        
        let qrCodeVC = DKQRCodeVC()
        qrCodeVC.QRCodeCallback = { result in
            self.searchTextView.text = result
        }
        let nav = UINavigationController(rootViewController: qrCodeVC)
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func clickJump(_ sender: UIButton) {
        jump()
    }
    
    func jump() {
        let urlStr = urlCorrection(url: self.searchTextView.text)
        guard let url = URL(string: urlStr) else {
            return
        }
        
//        if let h5Handler = DebugKit.share.h5Handler {
//            navigationController?.dismiss(animated: true, completion: {
//                h5Handler(urlStr)
//            })
//        } else {
//            let webVC = DKWebVC()
//            webVC.urlStr = url.absoluteString
//            navigationController?.pushViewController(webVC, animated: true)
//        }
       
        if !searchHistoricals.contains(urlStr) {
            searchHistoricals.insert(urlStr, at: 0)
            UserDefaults.standard.set(searchHistoricals, forKey: searchHistoricalsKey)
        }
        tableView.reloadData()
    }
    
    func urlCorrection(url: String) -> String {
        if url.count <= 0 {
            return url
        }
        
        if !url.hasPrefix("http://") && !url.hasPrefix("https://") {
            return "https://\(url)"
        }
        
        if url.hasPrefix(":") {
            return "https\(url)"
        }
        
        if url.hasPrefix("//") {
            return "https:\(url)"
        }
        
        if url.hasPrefix("/") {
            return "https:/\(url)"
        }
        
        return url
    }
    
    @objc func cleanCache() {
        searchHistoricals.removeAll()
        UserDefaults.standard.setValue(nil, forKey: searchHistoricalsKey)
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

extension DKH5VC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //判断输入的字是否是回车，即按下return
            textView.resignFirstResponder()
            jump()
            return false
        }
        return true
    }
}

extension DKH5VC: UITableViewDataSource, UITableViewDelegate {
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
