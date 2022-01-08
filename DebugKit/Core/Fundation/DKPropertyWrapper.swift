//
//  DKPropertyWrapper.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/12/19.
//

import Foundation


// MARK: - UserDefault
@propertyWrapper struct UserDefault<T> {
    let key: String
    let defaultValue: T
    
    public var wrappedValue: T {
        get {
            if let value = DebugKit.userDefault()?.value(forKey: key) as? T {
                return value
            } else {
                return defaultValue
            }
        }
        
        set {
            DebugKit.userDefault()?.setValue(newValue, forKey: key)
        }
    }
    
}
