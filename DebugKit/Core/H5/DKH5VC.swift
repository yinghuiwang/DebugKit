//
//  DKH5VC.swift
//  DebugKit
//
//  Created by 王英辉 on 2021/8/30.
//

import UIKit

class DKH5VC: UIViewController {

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        let debugKitBundle = Bundle(path: Bundle(for: Self.self).path(forResource: "Core.bundle", ofType: nil) ?? "")
        super.init(nibName: "DKH5VC", bundle: debugKitBundle)
    }
    
    public required init?(coder: NSCoder) {
        let debugKitBundle = Bundle(path: Bundle(for: Self.self).path(forResource: "Core.bundle", ofType: nil) ?? "")
        super.init(nibName: "DKH5VC", bundle: debugKitBundle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
