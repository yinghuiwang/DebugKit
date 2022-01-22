//
//  DKMsgSimulation.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/9/8.
//

import UIKit


struct DKMSMessage: Codable {
    let name: String
    let body: String
}

enum DKMSSendType {
    case toClient
    case toServer
}

class DKMsgSimulation: NSObject {

    var list: [DKMSMessage] = []
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
            
            guard let list = try? JSONDecoder().decode([DKMSMessage].self, from: data) else {
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
    
    func sendMsg(key: String, body: String, sendType: DKMSSendType) {
        let message = DKMSMessage(name: key, body: body)
        
        list = list.filter { $0.name != message.name }
        list.insert(message, at: 0)
        
        refreshView()
        
        switch sendType {
        case .toClient:
            DebugKit.share.mediator.notinationCenter.send(name: "Send ws to client", content: body)
        case .toServer:
            DebugKit.share.mediator.notinationCenter.send(name: "Send ws to server", content: body)
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
            messagesPath = NSString(string: firstPath).appendingPathComponent("MsgSimulation_messages.json")
        }
        return messagesPath
    }
}
