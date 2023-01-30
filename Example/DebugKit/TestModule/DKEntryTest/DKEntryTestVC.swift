//
//  DKEntryTestVC.swift
//  DebugKit_Example
//
//  Created by 王英辉 on 2021/9/4.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import DebugKit

class DKEntryTestVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func showEntry(_ sender: Any) {
        DebugKit.share.openDebug()
    }
    
    @IBAction func presentSelfVC(_ sender: Any) {
        let entryTestVC = DKEntryTestVC()
        present(entryTestVC, animated: true)
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
