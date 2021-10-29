//
//  DKUserDefaultsVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/8.
//

import UIKit

class DKUserDefaultsVC: UIViewController {

    @IBOutlet weak var searchHistryCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    let searchBar = UISearchBar()
    var viewModel = DKUserDefaultsViewModel()
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DKUserDefaultsVC", bundle: DebugKit.dk_bundle(name: "UserDefaults"))
    }
    
    public required init?(coder: NSCoder) {
        super.init(nibName: "DKUserDefaultsVC", bundle: DebugKit.dk_bundle(name: "UserDefaults"))
    }
    
    open override func viewDidLoad() {        
        setupViews()
        loadData()
    }
    
    func setupViews() {
        tableView.tableFooterView = UIView()
        
        searchBar.returnKeyType = .search
        searchBar.delegate = self
        searchBar.placeholder = "keyword"
        
        navigationItem.titleView = searchBar
        
        searchHistryCollectionView.register(UINib(nibName: DKUDDeleteHistryCell.cellName,
                                              bundle: DebugKit.dk_bundle(name: "UserDefaults")),
                                        forCellWithReuseIdentifier: DKUDDeleteHistryCell.cellName)
    }
    
    func loadData() {
        viewModel.reload()
        tableView.reloadData()
        searchHistryCollectionView.reloadData()
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
        searchBar.resignFirstResponder()
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
            searchHistryCollectionView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
}

extension DKUserDefaultsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.deleteHistoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DKUDDeleteHistryCell.cellName, for: indexPath) as! DKUDDeleteHistryCell
        
        let searchText = viewModel.deleteHistoryList[indexPath.row]
        cell.title.text = searchText;
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let searchText = viewModel.deleteHistoryList[indexPath.row]
        let width = DKUDDeleteHistryCell.cellW(SearchText: searchText)
        
        return CGSize(width: width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let searchText = viewModel.deleteHistoryList[indexPath.row]
        searchBar.text = searchText;
        viewModel.search(keyword: searchText)
        tableView.reloadSections([0], with: .automatic)
        searchBar.resignFirstResponder()
    }
}

extension DKUserDefaultsVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        viewModel.search(keyword: searchBar.text)
        tableView.reloadSections([0], with: .automatic)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(keyword: searchBar.text)
        tableView.reloadSections([0], with: .automatic)
    }
}
