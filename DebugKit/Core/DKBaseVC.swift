//
//  DKBaseVC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/31.
//

import UIKit

class DKBaseVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // 点击屏幕空白处收起键盘
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    
}
