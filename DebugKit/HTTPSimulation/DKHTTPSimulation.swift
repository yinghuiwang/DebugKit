//
//  DKMsgSimulation.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/8.
//

import UIKit


struct DKHTTPMessage: Codable {
    let key: String
    let method: String
    let host: String
    let api: String
    let param: String?
}

class DKHTTPSimulation: NSObject {

    var list: [DKHTTPMessage] = []
    var originalJson: String?
    let messagesPath: String
    
    var refreshViewCellback: (() -> Void)?
    
    override init() {
        messagesPath = Self.messagesPath()
        super.init()
    }
    
    func reload() {
        DispatchQueue.global().async {
            guard let data = try? Data.init(contentsOf: URL(fileURLWithPath: self.messagesPath)) else {
                DebugKit.log("DKMS: 读取文件失败")
                return
            }
            
            guard let list = try? JSONDecoder().decode([DKHTTPMessage].self, from: data) else {
                DebugKit.log("DKMS: json解析失败")
                return
            }
            
            DispatchQueue.main.async {
                self.list = list
                self.refreshView()
            }
        }
    }
    
    func delete(index: Int) {
        
        list.remove(at: index)
        
        saveMessages()
    }
    
    func send(key: String, method: String, host: String, api: String, param: String?, responseCallback: ((String)-> Void)?) {
        let message = DKHTTPMessage(key: key, method: method, host: host, api: api, param: param)
        
        list = list.filter { $0.api != message.api }
        list.insert(message, at: 0)
        
        refreshView()
        
        var body: [String: Any] = [:]
        body["method"] = method
        body["host"] = host
        body["api"] = api
        body["param"] = param?.toDictionary()
        
        DebugKit.share.mediator.router.requset(url: "dk://SendHttpToServer", params: body) { response in
            if let response = response as? String {
                responseCallback?(response)
            }
        } fail: { _ in
            
        }

        saveMessages()
    }
    
    func saveMessages() {
        DispatchQueue.global().async {
            guard let data = (try? JSONEncoder().encode(self.list)) else {
                DebugKit.log("DKMS: Encode失败")
                return
            }
            
            do {
                try data.write(to: URL(fileURLWithPath: self.messagesPath), options: .atomic)
            } catch {
                DebugKit.log("DKMS: 存储失败\(error)")
            }
        }
    }
    
    func refreshView() {
        if let cellback = refreshViewCellback {
            cellback()
        }
    }
    
    static func messagesPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        var messagesPath = ""
        if let firstPath = paths.first {
            messagesPath = NSString(string: firstPath).appendingPathComponent("HTTPSimulation_requests.json")
        }
        return messagesPath
    }
}
