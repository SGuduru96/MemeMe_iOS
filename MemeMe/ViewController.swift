//
//  ViewController.swift
//  MemeMe
//
//  Created by Sunny Guduru on 8/24/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var memeView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var pickItemBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraItemBarButton: UIBarButtonItem!
    
    // MARK: Properties
    var memeModel: MemeModel! = nil
    var textFieldAttributes = [NSAttributedString.Key: Any]()
    
    enum Buttons: Int {
        case Album
        case Camera
    }
    
    // MARK: View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let centerParagraph = NSMutableParagraphStyle()
        centerParagraph.alignment = .center
        
        textFieldAttributes = [
            NSAttributedString.Key.paragraphStyle: centerParagraph,
            NSAttributedString.Key.strokeColor: UIColor.black,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedString.Key.strokeWidth:  -7.0
        ]
        
        // Set attributes for text fields
        topTextField.defaultTextAttributes = textFieldAttributes
        bottomTextField.defaultTextAttributes = textFieldAttributes
        
        // set delegate for text fields
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        // Set text to empty
        topTextField.text = ""
        bottomTextField.text = ""
        
        // Enable picker buttons based on source type availability
        pickItemBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        cameraItemBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotification()
    }
    
    // MARK: Methods
    func loadMeme() {
        // Set memeView subview contents
        imageView.image = memeModel.image
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        // Enable editing for text fields
        topTextField.isEnabled = true
        bottomTextField.isEnabled = true
    }
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Callback
    @objc func keyboardWillShow(_ notification: Notification) {
        // move frame up by keyboard height
        if bottomTextField.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // reset frame of view to 0
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    // MARK: Actions
    @IBAction func pickAnImage(_ sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        // set imagePicker properties
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        // set the source based on which bar button was pressed
        imagePicker.sourceType = .camera // camera type by default
        if sender.tag == Buttons.Album.rawValue {
            imagePicker.sourceType = .photoLibrary
        }
        
        // check if public.image is an available mediaType
        if let _ = UIImagePickerController.availableMediaTypes(for: imagePicker.sourceType)?.contains("public.image") {
            // set mediaType
            imagePicker.mediaTypes = ["public.image"]
            // present imagePicker modally
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // When the memeView is pinched, toggle between aspectfit and aspectfill for imageView's content mode
    @IBAction func adjustImageContentMode(_ sender: UIPinchGestureRecognizer) {
        if sender.state == .ended {
            // zoom out
            if sender.scale < 1 {
                imageView.contentMode = .scaleAspectFit
            } else if sender.scale > 1 {
                imageView.contentMode = .scaleAspectFill
            }
        }
//        sender.view?.contentMode
    }
    
    // MARK: Delegate Functions
    // cancel imagePicker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // image picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            memeModel = MemeModel(image: image)
            loadMeme()
        }
        
        // dismiss the picker modal view
        picker.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text == "" && topTextField.isFirstResponder {
            textField.text = "TOP"
        } else if textField.text == "" && bottomTextField.isFirstResponder {
            textField.text = "BOTTOM"
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

