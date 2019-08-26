//
//  MemeTextFieldDelegate.swift
//  MemeMe
//
//  Created by Sunny Guduru on 8/25/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import Foundation
import UIKit

class MemeTextFieldDelegate: NSObject, UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
