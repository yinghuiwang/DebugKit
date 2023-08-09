//
//  DkAppConfig.swift
//  Alamofire
//
//  Created by kyleboy on 2023/1/18.
//

import UIKit


public struct AppConfigItem {
    let name: String
    let selectContent: Any
    let value: String
    let key: String
    let type: ConfigType
    
    public enum ConfigType {
        case int
        case text
    }
    
    public init(name: String, selectContent: Any = "", value: String, key: String, type: ConfigType) {
        self.name = name
        self.selectContent = selectContent
        self.value = value
        self.key = key
        self.type = type
    }
}

open class DkAppConfig: NSObject {
    @objc public static let shared = DkAppConfig()
    
    var items: [AppConfigItem] = []
    
    public func add(item: AppConfigItem) {
        items.append(item)
    }
    
    public func add(defaultValue: String, key: String) {
        let hKey = searchHistoricalsKey(key: key)
        var searchHistoricals = DebugKit.userDefault()?.array(forKey: hKey) as? [String] ?? []
        if !searchHistoricals.contains(defaultValue) {
            searchHistoricals.insert(defaultValue, at: 0)
            DebugKit.userDefault()?.set(searchHistoricals, forKey: hKey)
        }
    }
    
    func searchHistoricalsKey(key: String) -> String {
        return "DK\(key)SearchHistoricalsKey"
    }
}
