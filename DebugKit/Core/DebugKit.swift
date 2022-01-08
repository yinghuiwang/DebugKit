//
//  DebugKit.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

enum DKUserDefuaultKey: String {
    case openDebug
}

struct DKDebugLogKey {
    static let dk = "DK"
}

open class DebugKit: NSObject {
    
    @objc public static let share = DebugKit()
    private override init() {}
    
    private var debugNC: UINavigationController?
    
    @objc public var enableConsoleLog = false
    
    @objc public let mediator = DKMediator()
    
    /// 工具箱
    @objc public let toolBox = DKToolBox()
    
    var enterView: DKEnterView?
    
    
    @objc public func setup() {
        if let openDebug = DebugKit.userDefault()?.bool(forKey: DKUserDefuaultKey.openDebug.rawValue),
           openDebug {
            self.openDebug()
        }
    }
    
}

extension DebugKit {
    // MARK: - PrivateMethod
    @objc func jumpToolBoxVC() {
        guard let topViewController = DebugKit.topViewController() else {
            return
        }
        
        if let debugNC = self.debugNC {
            if debugNC.presentingViewController == nil {
                topViewController.present(debugNC, animated: true, completion: nil)
            } else {
                debugNC.dismiss(animated: true, completion: nil)
            }
            return
        }
        
        let debugVC = DKToolBoxVC(toolBox: toolBox)
        let navigationController = UINavigationController(rootViewController: debugVC)
        topViewController.present(navigationController, animated: true, completion: nil)
        self.debugNC = navigationController
    }
    
    // MARK: - PublicMethod
    @objc public func openDebug() {
        if enterView != nil { return }
        enterView = DKEnterView.view()
        enterView?.addTarget(self, action: #selector(jumpToolBoxVC), for: .touchUpInside)
        enterView?.show()
        
        DebugKit.userDefault()?.setValue(true, forKey: DKUserDefuaultKey.openDebug.rawValue)
    }
    
    @objc public func enterViewMoveToTopView() {
        if let enterView = self.enterView {
            enterView.show()
        }
    }
    
    public func closeDebug() {
        guard let enterView = enterView else { return }
        
        enterView.removeFromSuperview()
        self.enterView = nil
        self.debugNC = nil
        
        DebugKit.userDefault()?.setValue(false, forKey: DKUserDefuaultKey.openDebug.rawValue)
    }
}
