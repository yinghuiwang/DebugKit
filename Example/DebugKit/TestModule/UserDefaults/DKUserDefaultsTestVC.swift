//
//  DKUserDefaultsTestVC.swift
//  DebugKit_Example
//
//  Created by 王英辉 on 2021/9/8.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class DKUserDefaultsTestVC: UIViewController {

    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBtn.layer.cornerRadius = 4
        addBtn.layer.borderWidth = 0.5
        addBtn.layer.borderColor = UIColor.systemBlue.cgColor
        
    }

    @IBAction func addAction(_ sender: Any) {
        guard let key = keyTextField.text,
              let value = valueTextField.text,
              key.count > 0, value.count > 0 else {
            return
        }
        
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        keyTextField.resignFirstResponder()
        valueTextField.resignFirstResponder()
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
