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
    private(set) var tools: [Tool] = []
    @objc public var enableConsoleLog = false
    /// 工具箱
    @objc public let toolBox = DKToolBox()
    
    var enterView: DKEnterView?
    
    @objc public var h5Handler: ((String) -> Void)?
    
    /// 时间触发, $0是key，$1是Value
    @objc public var actionHandle: ((_ key: String, _ value: String) -> Void)?
    
    
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
    
    public func closeDebug() {
        guard let enterView = enterView else { return }
        
        enterView.removeFromSuperview()
        self.enterView = nil
        self.debugNC = nil
        
        DebugKit.userDefault()?.setValue(false, forKey: DKUserDefuaultKey.openDebug.rawValue)
    }
}

// MARK: - Utils
extension DebugKit {
    static func topViewController(controller: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    static func alert(message: String?, ok:(()-> Void)?, cancel:(()->Void)?) {
        let alertController = UIAlertController.init(title: "提示", message: message, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            if let cancel = cancel { cancel() }
        }))
        
        alertController.addAction(UIAlertAction(title: "确认", style: .default, handler: { _ in
            if let ok = ok { ok() }
        }))
        
        topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
    static func openAppSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    static func log(_ msg: String) {
        guard DebugKit.share.enableConsoleLog else {
            return
        }
        let timeStr = String(format: "%.4f", Date().timeIntervalSince1970)
        debugPrint("[\(timeStr)][\(DKDebugLogKey.dk)]\(msg)")
    }
    
    static func sizeFrom750(value: CGFloat) -> CGFloat {
        value * UIScreen.main.bounds.size.width / 750
    }
    
    static func dk_bundle(name: String) -> Bundle? {
        Bundle(path: Bundle(for: Self.self).path(forResource: "\(name).bundle", ofType: nil) ?? "")
    }
    
    // MARK: App Info
    static func appName() -> String {
        var _appName: String = ""
        if _appName.count <= 0 {
            if let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") as? String {
                _appName = appName
            } else {
                _appName = ProcessInfo.processInfo.processName
            }
        }
        return _appName
    }
    
    // MARK: 分享
    /// 分享内容
    /// - Parameters:
    ///   - object: 分享内容：support NSString、NSURL、UIImage
    ///   - fromVC: from viewController
    @objc public static func share(object: AnyObject, fromVC: UIViewController) {
        let objectsToShare = [object] //support NSString、NSURL、UIImage
        let controller = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        fromVC.present(controller, animated: true, completion: nil)
    }
    
    // MARK: UserDefault
    static func userDefault() -> UserDefaults? {
        UserDefaults(suiteName: "DebugKit")
    }
    
    // toast
    public static func showToast(text: String) {        
        let showToast = {
            guard let currentWindow = UIApplication.shared.keyWindow else {
                return
            }

            DKToast.show(text: text, inView: currentWindow)
        }
                
        if Thread.current.isMainThread {
            showToast()
        } else {
            DispatchQueue.main.async {
                showToast()
            }
        }
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(hex: hex, alpha: 1)
    }
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        self.init(red: CGFloat(((hex >> 16) & 0xFF))/255.0,
                green: CGFloat(((hex >> 8) & 0xFF))/255.0,
                blue: CGFloat((hex & 0xFF))/255.0,
                alpha: alpha)
    }
}

// MARK: - PropertyWrapper
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

