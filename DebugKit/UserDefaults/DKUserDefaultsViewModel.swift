//
//  DKUserDefaultsViewModel.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/8.
//

import UIKit

class DKUserDefaultsViewModel: NSObject {

    var modelList: [DKUserDefaultModel] = []
    
    var showModelList: [DKUserDefaultModel] = []
    
    func reload() {
        let dic = UserDefaults.standard.dictionaryRepresentation()
        modelList = dic.map({ (key, value) in
            DKUserDefaultModel(key: key, value: value)
        })
        
        modelList.sort { model1, model2 in
            model1.key.lowercased() < model2.key.lowercased()
        }

        showModelList = modelList
    }
    
    func delete(model: DKUserDefaultModel) {
        UserDefaults.standard.setValue(nil, forKey: model.key)
        reload()
    }
    
    func search(keyword: String?) {
        if let keyword = keyword, keyword.count > 0 {
            showModelList = modelList.filter { $0.key.contains(keyword) }
        } else {
            showModelList = modelList
        }   
    }
    
}


struct DKUserDefaultModel: Equatable {
    let key: String
    let value: Any
    
    static func == (lhs: DKUserDefaultModel, rhs: DKUserDefaultModel) -> Bool {
        lhs.key == rhs.key
    }
}
