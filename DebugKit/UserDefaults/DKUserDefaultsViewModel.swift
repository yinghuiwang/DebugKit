//
//  DKUserDefaultsViewModel.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/8.
//

import UIKit

class DKUserDefaultsViewModel: NSObject {

    var modelList: [DKUserDefaultModel] = []
    let deleteHistoryListKey = "deleteHistoryListKey"
    var searchText: String?
    var showModelList: [DKUserDefaultModel] = []
    var deleteHistoryList: [String] {
        get {
            DebugKit.userDefault()?.stringArray(forKey: deleteHistoryListKey) ?? []
        }
        set {
            DebugKit.userDefault()?.set(newValue, forKey: deleteHistoryListKey)
        }
    }
    
    func reload() {
        loadUserDefaults()
        processData()
        
        DebugKit.share.mediator.router.requset(url: "dk://getAppSettings", success:  { [weak self] responds in
            guard let settings = responds as? [[String: Any]] else { return }
            self?.modelList.append(contentsOf: settings.compactMap({ dict in
                if let flag = dict["flag"] as? String,
                   let key = dict["key"] as? String,
                   let value = dict["value"] {
                    return DKUserDefaultModel(flag: flag, key: key, value: value)
                }
                return nil
            }))
            self?.processData()
        })
    }
    
    func delete(model: DKUserDefaultModel) {
        if model.flag == "UserDefaults" {
            deleteUserDefaults(key: model.key)
        } else {
            DebugKit.share.mediator.router.requset(url: "dk://removeAppSettings", params: ["flag": model.flag, "key": model.key])
        }
        
        if let searchText = self.searchText {
            deleteHistoryList = deleteHistoryList.filter { $0 != searchText }
            deleteHistoryList.insert(searchText, at: 0)
        }
        
        reload()
    }
    
    func processData() {
        modelList.sort { model1, model2 in
            model1.key.lowercased() < model2.key.lowercased()
        }

        if let searchText = searchText, searchText.count > 0 {
            showModelList = modelList.filter { $0.key.lowercased().contains(searchText.lowercased()) }
        } else {
            showModelList = modelList
        }
    }
    
    func search(keyword: String?) {
        searchText = keyword
        reload()
    }
}

extension DKUserDefaultsViewModel {
    
    func loadUserDefaults() {
        let dic = UserDefaults.standard.dictionaryRepresentation()
        
        modelList = dic.map({ (key, value) in
            DKUserDefaultModel(flag: "UserDefaults", key: key, value: value)
        })
    }
    
    func deleteUserDefaults(key: String) {
        UserDefaults.standard.setValue(nil, forKey: key)
    }
    
}


struct DKUserDefaultModel: Equatable {
    let flag: String
    let key: String
    let value: Any
    
    
    static func == (lhs: DKUserDefaultModel, rhs: DKUserDefaultModel) -> Bool {
        lhs.key == rhs.key && lhs.flag == rhs.flag
    }
}
