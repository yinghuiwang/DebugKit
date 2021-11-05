//
//  DKMsgSimulationVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/30.
//

import UIKit

class DKMsgSimulationVC: DKBaseVC {

    @IBOutlet weak var bodyTextView: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    let nameTextField = UITextField()
    
    let searchHistoricalsKey = "DKSearchHistoricalsKey"
    
    let msgSimulation = DKMsgSimulation()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKMsgSimulationVC", bundle: DebugKit.dk_bundle(name: "MsgSimulation"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKMsgSimulationVC", bundle: DebugKit.dk_bundle(name: "MsgSimulation"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        loadData()
        
        msgSimulation.refreshViewCellback = { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func loadData() {
        msgSimulation.reload()
    }
    
    func setupViews() {
        nameTextField.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        nameTextField.returnKeyType = .done
        nameTextField.delegate = self
        nameTextField.placeholder = "name"
        nameTextField.clearButtonMode = .always
        
        navigationItem.titleView = nameTextField
        
        bodyTextView.delegate = self
        bodyTextView.returnKeyType = .done
        
        tableView.tableFooterView = UIView()
        tableView.tableFooterView?.isUserInteractionEnabled = false
        
        sendBtn.layer.cornerRadius = 5
        sendBtn.layer.masksToBounds = true
        sendBtn.layer.borderWidth = 0.5
        sendBtn.layer.borderColor = UIColor.systemBlue.cgColor
        
    }
    
    @IBAction func clickJump(_ sender: UIButton) {
        guard let name = self.nameTextField.text else {
            return
        }
        
        msgSimulation.sendMsg(key: name, body: self.bodyTextView.text)
    }
    
    @IBAction func clickClear(_ sender: Any) {
        bodyTextView.text = ""
    }
    @objc func cleanCache() {
//        searchHistoricals.removeAll()
//        UserDefaults.standard.setValue(nil, forKey: searchHistoricalsKey)
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
}

extension DKMsgSimulationVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            //判断输入的字是否是回车，即按下return
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension DKMsgSimulationVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgSimulation.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: NSStringFromClass(Self.self))
            cell!.accessoryType = .disclosureIndicator
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 12)
        }
        
        let message = msgSimulation.list[indexPath.item]
        
        cell!.textLabel?.text = message.name
        cell!.detailTextLabel?.text = message.body
        return cell!
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = msgSimulation.list[indexPath.item]
        self.nameTextField.text = message.name
        self.bodyTextView.text = message.body
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        nameTextField.resignFirstResponder()
        bodyTextView.resignFirstResponder()
    }
}

extension DKMsgSimulationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
