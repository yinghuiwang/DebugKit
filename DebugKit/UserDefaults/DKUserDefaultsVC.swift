//
//  DKUserDefaultsVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/8.
//

import UIKit

class DKUserDefaultsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var viewModel = DKUserDefaultsViewModel()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKUserDefaultsVC", bundle: DebugKit.dk_bundle(name: "UserDefaults"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKUserDefaultsVC", bundle: DebugKit.dk_bundle(name: "UserDefaults"))
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
        viewModel.reload()
        tableView.reloadData()
    }
    
}

extension DKUserDefaultsVC: UITableViewDelegate, UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.showModelList.count;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Self.self))
        
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: NSStringFromClass(Self.self))
            cell!.accessoryType = .disclosureIndicator
        }
        
        let model = viewModel.showModelList[indexPath.item]
        
        
        cell!.textLabel?.text = model.key
        cell!.detailTextLabel?.text = "\(model.value)"
        return cell!
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let model = viewModel.showModelList[indexPath.row]
            viewModel.delete(model: model)
            tableView.reloadSections([0], with: .automatic)
        }
    }
}
