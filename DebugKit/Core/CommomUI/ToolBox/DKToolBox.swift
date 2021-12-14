//
//  DKToolBox.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/10/31.
//

import Foundation

struct DKTool {
    let name: String
    let summay: String
    let vcClassName: String?
    let clickHandle: ((UIViewController) -> Void)?
}

public class DKToolBox: NSObject {
    private(set) var tools: [DKTool] = []
    
    override init() {
        super.init()
        
        do {
            let vcClassName = "DebugKit.DKFLLogFileListVC"
            if NSClassFromString(vcClassName) != nil {
                tools.append(DKTool(name: "Log",
                                    summay: "查看本地记录的日志",
                                    vcClassName: vcClassName,
                                    clickHandle: nil))
            }
        }
        
        do {
            let vcClassName = "DebugKit.DKUserDefaultsVC"
            if NSClassFromString(vcClassName) != nil {
                tools.append(DKTool(name: "UserDefaults",
                                    summay: "管理本地NSUserDefaults的工具",
                                    vcClassName:  vcClassName,
                                    clickHandle: nil))
            }
        }
        
        do {
            let vcClassName = "DebugKit.DKH5VC"
            if NSClassFromString(vcClassName) != nil {
                tools.append(DKTool(name: "H5调试",
                                    summay: "提供跳转到包房内部WebView页面的方法",
                                    vcClassName: vcClassName,
                                    clickHandle: nil))
            }
        }
        
        do {
            let vcClassName = "DebugKit.DKMsgSimulationVC"
            if NSClassFromString(vcClassName) != nil {
                tools.append(DKTool(name: "WS消息发送",
                                    summay: "提供房间内消息模拟发送",
                                    vcClassName: vcClassName,
                                    clickHandle: nil))
            }
        }
    }
    
    /// 时间复杂度O(n)
    @objc public func add(name: String,
                          summary: String,
                          vcClassName: String?,
                          clickHandle: ((UIViewController) -> Void)?) {
        let tool = DKTool(name: name, summay: summary, vcClassName: vcClassName, clickHandle: clickHandle)
        tools = tools.filter {$0.name != tool.name }
        tools.append(tool)
    }
}
