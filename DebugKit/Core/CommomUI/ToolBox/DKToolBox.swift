//
//  DKToolBox.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/10/31.
//

import Foundation


@objc protocol DKTool {
    static func configTool()
}

struct DKToolInfo {
    let name: String
    let summay: String
    let priority: Int
    let clickHandle: ((UIViewController) -> Void)?
}

public class DKToolBox: NSObject {
    private(set) var tools: [DKToolInfo] = []
    private var loaded = false
    
    override init() {
        super.init()
    }
    
    func loadTools(success:(() -> Void)?) {
        guard !loaded else {
            success?()
            return
        }
        
        loaded = true
        
        DispatchQueue.global().async {
            // 模块配置
            let routables: [DKTool.Type] = DebugKit.classes(implementing: DKTool.self)
            routables.forEach { tool in
                tool.configTool()
            }
            
            DispatchQueue.main.async {
                success?()
            }
        }
    }
    
    /// 时间复杂度O(n)
    @objc public func add(name: String,
                          summary: String,
                          priority: Int = 500,
                          clickHandle: ((UIViewController) -> Void)? = nil) {
        let tool = DKToolInfo(name: name, summay: summary, priority: priority, clickHandle: clickHandle)
        tools = tools.filter {$0.name != tool.name }
        tools.append(tool)
        
        tools.sort { $0.priority >= $1.priority }
    }
}
