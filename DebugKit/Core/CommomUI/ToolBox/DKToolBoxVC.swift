//
//  DKToolBoxVC.swift
//  ktv
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

open class DKToolBoxVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var toolBox: DKToolBox?
    
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKToolBoxVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKToolBoxVC", bundle: DebugKit.dk_bundle(name: "Core"))
    }
    
    convenience init(toolBox: DKToolBox) {
        self.init()
        self.toolBox = toolBox
    }
    
    deinit {
        DebugKit.log("DKToolBoxVC deinit")
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    open override func viewDidLoad() {
        title = "DebugKit"
        
        setupViews()
        loadData()
    }
    
    func setupViews() {
        let setIcon = UIImage(contentsOfFile: DebugKit.dk_bundle(name: "Core")?.path(forResource: "dk_icon_set.png", ofType: nil) ?? "")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: setIcon, style: .plain, target: self, action: #selector(moreClick))
    }
    
    func loadData() {
        guard let toolBox = self.toolBox else { return }
        toolBox.loadTools { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    @objc func moreClick() {
        navigationController?.pushViewController(DKTBSetupVC(), animated: true)
    }
}

extension DKToolBoxVC {
    
}

extension DKToolBoxVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toolBox?.tools.count ?? 0;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
        }
        
        guard let tool = toolBox?.tools[indexPath.item] else {
            return cell!
        }
        
        cell!.accessoryType = .disclosureIndicator
        cell!.textLabel?.text = tool.name
        cell!.detailTextLabel?.text = tool.summay
        
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tool = toolBox?.tools[indexPath.item] else { return }
        
        tool.clickHandle?(self)
    }
}


