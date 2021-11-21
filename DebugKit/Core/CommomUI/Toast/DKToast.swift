//
//  DKToast.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/28.
//

import UIKit

class DKToast: NSObject {
    static func show(text: String, inView: UIView) {        
        let containerView = UIView()
        containerView.backgroundColor = UIColor(hex: 0x000000, alpha: 0.8)
        containerView.layer.cornerRadius = 5
        containerView.layer.masksToBounds = true
        containerView.alpha = 0;
        inView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.centerXAnchor.constraint(equalTo: inView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: inView.centerYAnchor).isActive = true
        containerView.widthAnchor.constraint(lessThanOrEqualTo: inView.widthAnchor, multiplier: 1, constant: -20).isActive = true
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = text;
        label.textAlignment = .center
        label.numberOfLines = 0;
        label.textColor = UIColor.white
        containerView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 10).isActive = true
        label.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -10).isActive = true
        label.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        
        UIView.animate(withDuration: 0.3) {
            containerView.alpha = 1;
        }
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            UIView.animate(withDuration: 0.3) {
                containerView.alpha = 0;
            } completion: { _ in
                containerView.removeFromSuperview()
            }
        }
    }
}
