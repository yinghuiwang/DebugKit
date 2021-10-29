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
        let dic = UserDefaults.standard.dictionaryRepresentation()
        modelList = dic.map({ (key, value) in
            DKUserDefaultModel(key: key, value: value)
        })
        
        modelList.sort { model1, model2 in
            model1.key.lowercased() < model2.key.lowercased()
        }

        if let searchText = searchText, searchText.count > 0 {
            showModelList = modelList.filter { $0.key.lowercased().contains(searchText.lowercased()) }
        } else {
            showModelList = modelList
        }
    }
    
    func delete(model: DKUserDefaultModel) {
        UserDefaults.standard.setValue(nil, forKey: model.key)
        
        if let searchText = self.searchText {
            deleteHistoryList = deleteHistoryList.filter { $0 != searchText }
            deleteHistoryList.insert(searchText, at: 0)
        }
        
        reload()
    }
    
    func search(keyword: String?) {
        searchText = keyword
        
        reload()
    }
}


struct DKUserDefaultModel: Equatable {
    let key: String
    let value: Any
    
    static func == (lhs: DKUserDefaultModel, rhs: DKUserDefaultModel) -> Bool {
        lhs.key == rhs.key
    }
}
