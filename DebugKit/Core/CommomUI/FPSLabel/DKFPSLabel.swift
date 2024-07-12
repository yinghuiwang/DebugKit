//
//  DKFPSLabel.swift
//  KTVLiveRoom
//
//  Created by 王英辉 on 2021/8/28.
//

import UIKit

class DKFPSLabel: UILabel {
    
    var link: CADisplayLink?
    var count: UInt = 0
    var lastTime: TimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupViews()
    }
    
    deinit {
        link?.invalidate()
    }
    
    func setupViews() {
        self.textAlignment = .center
        font = UIFont.systemFont(ofSize: 14)
        
        link = CADisplayLink(target: KTVLRFPSWeakProxy(target: self), selector: #selector(tick(link:)))
        link?.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
    }

    @objc func tick(link: CADisplayLink) {
        if lastTime == 0 {
            lastTime = link.timestamp
            return
        }
        
        count += 1
        let delta = link.timestamp - lastTime
        if delta < 1 { return }
        lastTime = link.timestamp
        let fps = count / UInt(delta)
        count = 0
        
        let progress = Double(fps) / 60.0
        let color = UIColor(hue: CGFloat(0.27 * progress), saturation: 1, brightness: 0.9, alpha: 1)
        textColor = color
        text = "\(fps)\nFPS"
        
    }
}


class KTVLRFPSWeakProxy: NSObject {
    weak var target: NSObjectProtocol?
    
    init(target: NSObjectProtocol) {
        self.target = target
        super.init()
    }
    
    override func responds(to aSelector: Selector!) -> Bool {
        return (target?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
    }
    
    override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return target
    }
}
