//
//  DebugKit.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

enum DKUserDefuaultKey: String {
    case openDebug
    case isRecording
}

struct DKDebugLogKey {
    static let dk = "DK"
}

open class DebugKit: NSObject {
    
    @objc public static let share = DebugKit()
    private override init() {}
    
    var debugNavC: UINavigationController?
    
    @objc public var enableConsoleLog = false
    @objc public var isRecording = true
    
    @objc public let mediator = DKMediator()
    
    /// 工具箱
    @objc public let toolBox = DKToolBox()
    
    var enterWindow: DKWindow?
    
    
    @objc public func setup() {
        if let isRecording = DebugKit.userDefault()?.bool(forKey: DKUserDefuaultKey.isRecording.rawValue), !isRecording {
            self.isRecording = isRecording
        }
        
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
        
        if let debugNC = self.debugNavC {
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
        self.debugNavC = navigationController
    }
    
    // MARK: - PublicMethod
    @objc public func openDebug() {
        if enterWindow != nil { return }
        
        enterWindow = DKWindow(startPoint: CGPoint(x: 10, y: 150))
        enterWindow?.show()
        
        self.isRecording = true
        DebugKit.userDefault()?.setValue(true, forKey: DKUserDefuaultKey.isRecording.rawValue)
        DebugKit.userDefault()?.setValue(true, forKey: DKUserDefuaultKey.openDebug.rawValue)
    }
    
    public func closeDebug() {
        guard let enterWindow = enterWindow else { return }
        
        enterWindow.isHidden = true
        enterWindow.windowLevel = .normal - 1000
        enterWindow.removeFromSuperview()
        self.enterWindow = nil
        self.debugNavC = nil
        
        DebugKit.userDefault()?.setValue(false, forKey: DKUserDefuaultKey.openDebug.rawValue)
    }
    
    public func closeDebugEntryAndRecording() {
        closeDebug()
        self.isRecording = false
        DebugKit.userDefault()?.setValue(false, forKey: DKUserDefuaultKey.isRecording.rawValue)
    }
}
