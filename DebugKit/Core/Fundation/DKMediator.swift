//
//  DKMediator.swift
//  DebugKit
//
//  Created by 王英辉 on 2022/1/8.
//

import Foundation

public class DKMediator: NSObject {
    @objc public let router = DKRouter()
    @objc public let notinationCenter = DKNotinationCenter()
}

struct DKRouterError: Error {
    let code: Int
    let errStr: String
}

extension DKRouterError: CustomNSError {
    static var errorDomain: String = "DKRouterError"
    var errorCode: Int {
        code
    }
}

extension DKRouterError: LocalizedError {
    var errorDescription: String? {
        errStr
    }
}

public class DKRouter: NSObject {
    public typealias Handle = ([String: Any]?, ((Any?) -> Void)?, ((Error)->Void)?) -> Void
    
    private var handleMap: [String: Handle] = [:]
    
    @objc public func register(url: String, handle: @escaping Handle) {
        guard let (baseUrl, _) = resolve(url: url) else { return }
        handleMap[baseUrl] = handle
    }
    
    @objc public func unRegister(url: String) {
        guard let (baseUrl, _) = resolve(url: url) else { return }
        handleMap.removeValue(forKey: baseUrl)
    }
    
    @objc public func requset(url: String, params p: [String: Any]? = nil, success:((Any?) -> Void)? = nil, fail:((Error)->Void)? = nil) {
        guard let (baseUrl, urlParams) = resolve(url: url),
              let handle = handleMap[baseUrl] else {
            fail?(DKRouterError(code: 404, errStr: "无匹配资源"))
            return
        }
        
        var params: [String: Any] = [:]
        
        p?.forEach({ (key, value) in
            params[key] = value
        })
        
        urlParams?.forEach({ (key, value) in
            params[key] = value
        })
        
        handle(params, success, fail)
    }
    
    @objc public func open(url: String, params p: [String: Any]? = nil) {
        requset(url: url, params: p)
    }
    
    private func resolve(url u: String) -> (baseURL: String, params: [String: Any]?)? {
        guard let url = URL(string: u) else { return nil }
         
        let baseURL: String = u.components(separatedBy: "?").first ?? ""
        var params: [String: Any]? = nil
    
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems {
            params = queryItems.reduce(into: [String: String]()) { (result, item) in
                result[item.name] = item.value
            }
        }
                
        return (baseURL , params)
    }
    
}


struct DKNotination {
    typealias Handle = (Any?)->Void
    
    let valid: () -> Bool
    let handle: Handle
    
    init(observer: AnyObject, handle h: @escaping Handle) {
        valid = { [weak observer] in return observer != nil}
        handle = h
    }
}

public class DKNotinationCenter: NSObject {
    public typealias Handle = (Any?)->Void
    
    var handleMap: [String: [DKNotination]] = [:]
    
    @objc public func add(observer: AnyObject, name: String, handle: @escaping Handle) {
        let notination = DKNotination(observer: observer, handle: handle)
        var handles: [DKNotination] = []
        if let originHandles = handleMap[name] {
            handles = originHandles
        }
        handles.append(notination)
        handleMap[name] = handles
        
    }
    
    @objc public func send(name: String, content: Any?) {
        guard let handles = handleMap[name] else { return }
        var newHandles = handles
        newHandles.removeAll { !$0.valid() }
        handleMap[name] = newHandles
        newHandles.forEach { $0.handle(content) }
    }
}
