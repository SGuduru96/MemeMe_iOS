//
//  imagePickerDelegate.swift
//  MemeMe
//
//  Created by Sunny Guduru on 8/25/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import Foundation
import UIKit

class ImagePickerDelegate: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    // MARK: Properties
    let hostingViewController: ViewController
    
    init(viewController vc: ViewController) {
        self.hostingViewController = vc
    }
    
    // MARK: Delegate Functions
    
    // cancel imagePicker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // image picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            hostingViewController.memeModel = MemeModel(image: image)
            hostingViewController.loadMeme()
        }
        
        // dismiss the picker modal view
        picker.dismiss(animated: true, completion: nil)
    }
}
