//
//  DKHTTPRequestHistoryVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2022/4/7.
//

import UIKit

class DKHTTPRequestHistoryVC: DKBaseVC {

    @IBOutlet weak var maskView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var msgSimulation: DKHTTPSimulation?
    
    var selecteMessage: ((DKHTTPMessage)->Void)?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKHTTPRequestHistoryVC", bundle: DebugKit.dk_bundle(name: "HTTPSimulation"))
    }

    public required init?(coder: NSCoder) {
        super.init(nibName: "DKHTTPRequestHistoryVC", bundle: DebugKit.dk_bundle(name: "HTTPSimulation"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupViews()
        loadData()
        
        msgSimulation?.refreshViewCellback = { [weak self] in
            self?.tableView.reloadData()
        }
        
    }

    func loadData() {
        msgSimulation?.reload()
    }

    func setupViews() {
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.isUserInteractionEnabled = false
    }

    
    @objc func cleanCache() {
//        guard let msgSimulation = self.msgSimulation else {
//            return
//        }
//        UserDefaults.standard.setValue(nil, forKey: msgSimulation.searchHistoricalsKey)
//        tableView.reloadData()
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
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}


extension DKHTTPRequestHistoryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgSimulation?.list.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))

        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(Self.self))
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 12)
        }

        if let message = msgSimulation?.list[indexPath.item] {
            cell!.textLabel?.text = "[\(message.method)]\(message.api.components(separatedBy: ".").last ?? "")"
            cell!.detailTextLabel?.text = message.api
        }
        
        return cell!
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let message = msgSimulation?.list[indexPath.item] {
            selecteMessage?(message)
            dismiss(animated: true)
        }
    }
}


