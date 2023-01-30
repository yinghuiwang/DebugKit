//
//  DKEnterView.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/27.
//

import UIKit

class DKEnterView: UIControl {
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
}
