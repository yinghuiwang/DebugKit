//
//  DKWindow.swift
//  AHAFoundation
//
//  Created by kyleboy on 2023/1/30.
//

import UIKit

class DKWindow: UIWindow {
    let entrySize: CGFloat = 60
    let margin: CGFloat = 10
    
    lazy var enterControl = {
        let view = DKEnterView.view()
        view.frame = bounds
        view.addTarget(self, action: #selector(jumpToolBoxVC), for: .touchUpInside)
        return view
    }()
    
    init(startPoint: CGPoint) {
        super.init(frame: CGRect(origin: startPoint, size: CGSize(width: entrySize, height: entrySize)))
        if #available(iOS 13.0, *) {
            if let scene = (UIApplication.shared.connectedScenes as NSSet).anyObject() as? UIWindowScene {
                self.windowScene = scene
            }
        }
        
        backgroundColor = UIColor.clear
        windowLevel = .statusBar + 100
        rootViewController = DKRootVC()
        
        rootViewController?.view.addSubview(enterControl)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        addGestureRecognizer(pan)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func show() {
        isHidden = false
    }
    
    @objc func jumpToolBoxVC() {
        DebugKit.share.jumpToolBoxVC()
    }
    
    @objc func panAction(_ sender: UIPanGestureRecognizer) {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        let viewCenter = center
        let viewSize = bounds.size
        let screenSize = UIScreen.main.bounds.size
        let radius = viewSize.width / 2.0
        let panPoint = sender.translation(in: keyWindow)
        
        var safeAreaInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: margin, bottom: 0, right: margin)
        if #available(iOS 11.0, *) { safeAreaInsets = keyWindow.safeAreaInsets }
        
        var centerX = viewCenter.x + panPoint.x > viewSize.width / 2 ? viewCenter.x + panPoint.x : viewCenter.x - (viewCenter.x - panPoint.x)
        centerX = min(max(safeAreaInsets.left + radius, centerX), screenSize.width - safeAreaInsets.right -  radius)
        
        
        var centerY = viewCenter.y + panPoint.y > radius / 2 ? viewCenter.y + panPoint.y : viewCenter.y - (viewCenter.y - panPoint.y)
        centerY = min(max(safeAreaInsets.top + radius, centerY), screenSize.height - safeAreaInsets.bottom - radius)
        
        center = CGPoint(x: centerX, y: centerY)
        sender.setTranslation(.zero, in: keyWindow)
        
        if sender.state == .ended {
            let velocity = sender.velocity(in: keyWindow)
            let magintude = sqrtf(Float((velocity.x * velocity.x) + (velocity.y * velocity.y)))
            let slidemMult = magintude / 200
            
            let slideFactor = 0.001 * slidemMult
            var finalPoint = CGPoint(x: viewCenter.x, y: viewCenter.y + (velocity.y * CGFloat(slideFactor)))
            finalPoint.y = min(max(finalPoint.y, radius + safeAreaInsets.top), screenSize.height - safeAreaInsets.bottom - radius)
            let isLeft = finalPoint.x < screenSize.width / 2
            
            let originX = isLeft ? safeAreaInsets.left: screenSize.width - entrySize - safeAreaInsets.right;
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.frame = CGRect(origin: CGPoint(x: originX, y: finalPoint.y - radius), size: self.frame.size)
            }, completion: nil)
        }
    }
}


class DKRootVC: UIViewController {
    
}
