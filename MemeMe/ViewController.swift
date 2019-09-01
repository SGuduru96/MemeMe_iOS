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
    // Meme Views
    @IBOutlet weak var memeView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // Interface Buttons
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var pickItemBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraItemBarButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    // MARK: Properties
    var memeModel: MemeModel! = nil
    var textFieldAttributes = [NSAttributedString.Key: Any]()
    var photoTaken: Bool = false
    var editorState: MemeEditorState = .WaitingForImage
    enum Buttons: Int {
        case Album
        case Camera
        case Share
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
        
        // set state and update subviews
        editorState = .WaitingForImage
        updateViewsToMatchState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
        
        // Enable picker buttons based on source type availability
        pickItemBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        cameraItemBarButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotification()
    }
    
    // MARK: Methods
    func saveMemedImage() {
        UIGraphicsBeginImageContextWithOptions(memeView.bounds.size, false, 0)
        memeView.drawHierarchy(in: memeView.bounds, afterScreenUpdates: true)
        memeModel.memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func imageContentModeTransition(toMode mode: UIView.ContentMode) {
        UIView.transition(
            with: imageView,
            duration: 0.33,
            options: .transitionCrossDissolve,
            animations: {
                self.imageView.contentMode = mode
        },
            completion: nil
        )
    }
    
    // MARK: Notification
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
        imagePicker.sourceType = .photoLibrary // camera type by default
        photoTaken = false
        if sender.tag == Buttons.Camera.rawValue {
            imagePicker.sourceType = .camera
            photoTaken = true
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
            var newContentMode: UIView.ContentMode?
            if sender.scale < 1 {
                // zoom out
                newContentMode = .scaleAspectFit
            } else if sender.scale > 1 {
                // zoom in
                newContentMode = .scaleAspectFill
            }
            
            if newContentMode != nil {
                imageContentModeTransition(toMode: newContentMode!)
            }
        }
    }
    
    @IBAction func cancelMeme(_ sender: UIButton) {
        editorState = .WaitingForImage
        updateViewsToMatchState()
    }
    
    @IBAction func saveMeme(_ sender: UIBarButtonItem) {
        saveMemedImage()
        
        // open action sheet
        var activityView: UIActivityViewController?
        if photoTaken {
            activityView = UIActivityViewController(activityItems: [memeModel.originalImage, memeModel.memedImage!], applicationActivities: nil)
        } else {
            activityView = UIActivityViewController(activityItems: [memeModel.memedImage!], applicationActivities: nil)
        }
        
        present(activityView!, animated: true, completion: nil)
    }
}

// MARK: State Management
extension ViewController {
    enum MemeEditorState {
        case EditingImage
        case WaitingForImage
    }
    
    func updateViewsToMatchState() {
        switch editorState {
        case .EditingImage:
            // Set memeView subview contents
            imageView.image = memeModel.originalImage
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            
            // Show textfields and enable editing
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            topTextField.isEnabled = true
            bottomTextField.isEnabled = true
            
            // Enable and show the cancel button
            cancelButton.isEnabled = true
            cancelButton.isHidden = false
            shareButton.isEnabled = true
        case .WaitingForImage:
            // Set memeView subview contnts to nil
            imageView.image = nil
            topTextField.text = nil
            bottomTextField.text = nil
            
            // Hide textfields and disable editing
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            topTextField.isEnabled = false
            bottomTextField.isEnabled = false
            
            // Hide the cancel button and share button and disable
            cancelButton.isHidden = true
            cancelButton.isEnabled = false
            shareButton.isEnabled = false
        }
    }
}

// MARK: Delegate Functions
extension ViewController {
    // cancel imagePicker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // image picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            memeModel = MemeModel(image: image)
            editorState = .EditingImage
            updateViewsToMatchState()
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
