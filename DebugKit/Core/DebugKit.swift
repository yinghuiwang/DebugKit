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

open class DebugKit: NSObject {
    
    @objc public static let share = DebugKit()
    private override init() {}
    private var navigationController: UINavigationController?
    
    @objc public func setup() {
        if let openDebug = DebugKit.userDefault()?.bool(forKey: DKUserDefuaultKey.openDebug.rawValue),
           openDebug {
            self.openDebug()
        }
    }
    var enterView: DKEnterView?
    
    @objc public var h5Handler: ((String) -> Void)?
}

extension DebugKit {
    // MARK: - PrivateMethod
    @objc func jumpToolBoxVC() {
        guard let topViewController = DebugKit.topViewController() else {
            return
        }
        
        if let navigationController = self.navigationController {
            if navigationController.presentingViewController == nil {
                topViewController.present(navigationController, animated: true, completion: nil)
            }            
            return
        }
        
        let debugVC = DKToolBoxVC()
        let navigationController = UINavigationController(rootViewController: debugVC)
        topViewController.present(navigationController, animated: true, completion: nil)
        self.navigationController = navigationController
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
        
        DebugKit.userDefault()?.setValue(false, forKey: DKUserDefuaultKey.openDebug.rawValue)
    }
}

// MARK: - Utils
extension DebugKit {
    static func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
        debugPrint("DK: \(msg)")
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
    static func share(object: AnyObject, fromVC: UIViewController) {
        let objectsToShare = [object] //support NSString、NSURL、UIImage
        let controller = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        fromVC.present(controller, animated: true, completion: nil)
    }
    
    // MARK: UserDefault
    static func userDefault() -> UserDefaults? {
        UserDefaults(suiteName: "DebugKit")
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

