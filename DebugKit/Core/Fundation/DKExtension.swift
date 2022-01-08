//
//  DKExtension.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/12/19.
//

import Foundation

// MARK: - DebugKit
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

// MARK: - UIColor
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
