//
//  DKToastTextVC.swift
//  DebugKit_Example
//
//  Created by 王英辉 on 2021/11/14.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

import DebugKit

class DKToastTestVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    @IBAction func showToast1(_ sender: Any) {
        DebugKit.showToast(text: "showToast1")
    }
    
    @IBAction func showToast2(_ sender: Any) {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            DebugKit.showToast(text: "showToast2")
        }
        
    }
    
    @IBAction func showToast3(_ sender: Any) {
        DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .seconds(3)) {
            DebugKit.showToast(text: "showToast3")
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
