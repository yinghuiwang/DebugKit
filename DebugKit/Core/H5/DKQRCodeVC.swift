//
//  DKQRCodeVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/31.
//

import UIKit

class DKQRCodeVC: DKBaseVC {

    var QRCodeCallback: ((String) -> Void)?
    var scaner: DKQRScanView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let scaner = self.scaner {
            scaner.removeFromSuperview()
            scaner.stopScanning()
            self.scaner = nil
        }
    }
    
    func setupViews() {
        self.title = "扫描二维码"
        if #available(iOS 13.0, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        
        let scaner = DKQRScanView(frame: view.bounds)
        scaner.delegate = self
        scaner.isShowScanLine = true
        scaner.isShowBorderLine = true
        scaner.isShowCornerLine = true
        let scanerW = DebugKit.sizeFrom750(value: 480)
        scaner.scanRect = CGRect(x: scaner.frame.size.width / 2 - scanerW / 2,
                                 y: DebugKit.sizeFrom750(value: 195),
                                 width: scanerW,
                                 height: scanerW)
        scaner.startScanning()
        
        view.addSubview(scaner)
        self.scaner = scaner
        scaner.startScanning()
    }
}


extension DKQRCodeVC: DKQRScanViewDelegate {
    func pickUp(scanView: DKQRScanView, message: String) {
        if message.count > 0 {
            dismiss(animated: true) {
                if let QRCodeCallback = self.QRCodeCallback {
                    QRCodeCallback(message)
                }
            }
        }
    }
    
    func aroundBrigtness(scanView: DKQRScanView, brightnessValue: String) {
        
    }
}
