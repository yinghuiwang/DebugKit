//
//  DKEnterView.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/27.
//

import UIKit

class DKEnterView: UIControl {
    
    let margin: CGFloat = 10
    let contentViewWH: CGFloat = 60
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var fpsLabel: UILabel!
    
    var contentConstraintTop: NSLayoutConstraint?
    var contentConstraintLeft: NSLayoutConstraint?
    
    
    static func view() -> Self {
        if let debugKitBundle = DebugKit.dk_bundle(name: "Core"),
           let enterView = debugKitBundle.loadNibNamed("DKEnterView", owner: Self.self, options: nil)?.first as? Self {
            return enterView
        } else {
            return Self()
        }
    }
    
    override func awakeFromNib() {
        setupViews()
    }
    
    func setupViews() {
        backgroundColor = .clear
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 10, height: 10)
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.6
        
        contentView.layer.cornerRadius = contentViewWH / 2.0
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor(red: 0, green: 250.0/250.0, blue: 154/250.0, alpha: 1).cgColor
        
    }
    
    @IBAction func panAction(_ sender: UIPanGestureRecognizer) {
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
            
            let originX = isLeft ? safeAreaInsets.left: screenSize.width - contentViewWH - safeAreaInsets.right;
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                self.contentConstraintTop?.constant = finalPoint.y - radius
                self.contentConstraintLeft?.constant = originX
                keyWindow.layoutIfNeeded()
            }, completion: nil)
        }
    }
}

extension DKEnterView {
    func show() {
        guard let keyWindow = keyWindow() else { return }
        keyWindow.addSubview(self)
        
        var safeAreaInsets: UIEdgeInsets = UIEdgeInsets(top: 20, left: margin, bottom: 0, right: margin)
        if #available(iOS 11.0, *) { safeAreaInsets = keyWindow.safeAreaInsets }
        
        translatesAutoresizingMaskIntoConstraints = false
        let screenSize = UIScreen.main.bounds.size
        let top = screenSize.height - 97 - 50 - safeAreaInsets.bottom
        contentConstraintTop = self.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: top)
        contentConstraintTop?.isActive = true
        contentConstraintLeft = self.leftAnchor.constraint(equalTo: keyWindow.leftAnchor, constant: screenSize.width - contentViewWH - safeAreaInsets.right)
        contentConstraintLeft?.isActive = true
    }
    
    func keyWindow() -> UIWindow? {
        return UIApplication.shared.delegate?.window!
    }
    
    
    // MARK: - Util
    
    
}
