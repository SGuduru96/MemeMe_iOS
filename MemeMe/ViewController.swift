//
//  ViewController.swift
//  MemeMe
//
//  Created by Sunny Guduru on 8/24/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var memeView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var pickImageItemBarButton: UIBarButtonItem!
    
    var memeModel: MemeModel! = nil
    lazy var imagePickerDelegate: ImagePickerDelegate = ImagePickerDelegate(viewController: self)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topTextField.text = ""
        bottomTextField.text = ""
        pickImageItemBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    func loadMeme() {
        imageView.image = memeModel.image
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        // set imagePicker properties
        imagePicker.delegate = imagePickerDelegate
        imagePicker.allowsEditing = false
        
        // set the source as photo library
        imagePicker.sourceType = .photoLibrary
        
        // check if public.image is an available mediaType
        if let _ = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)?.contains("public.image") {
            // set mediaType
            imagePicker.mediaTypes = ["public.image"]
            // present imagePicker modally
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

