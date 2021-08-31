//
//  ViewController.swift
//  DebugKit
//
//  Created by iyinghui@163.com on 08/30/2021.
//  Copyright (c) 2021 iyinghui@163.com. All rights reserved.
//

import UIKit
import DebugKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func openDebugKtiAction(_ sender: Any) {
        DebugKit.share.openDebug()
    }
}

