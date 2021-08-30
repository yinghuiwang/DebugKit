//
//  DebugKit.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/27.
//

import Foundation

open class DebugKit: NSObject {
    
    @objc public static let share = DebugKit()
    
    var enterView: DKEnterView?
    
    
    private override init() {}
    
    public func openLRDebug() {
        if enterView != nil { return }
        enterView = DKEnterView.view()
        enterView?.addTarget(self, action: #selector(jumpDebugVC), for: .touchUpInside)
        enterView?.show()
    }
    
    @objc func jumpDebugVC() {
        guard let topViewController = UIApplication.topViewController() else {
            return
        }
        
        let debugVC = DKToolBoxVC()
        let navigationController = UINavigationController(rootViewController: debugVC)
        topViewController.present(navigationController, animated: true, completion: nil)
    }
}


extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
}
