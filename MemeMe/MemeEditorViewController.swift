//
//  ViewController.swift
//  MemeMe
//
//  Created by Sunny Guduru on 8/24/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    
    // Meme Views
    @IBOutlet weak var memeView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // Interface Buttons
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var pickItemBarButton: UIBarButtonItem!
    @IBOutlet weak var cameraItemBarButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    // MARK: Properties
    
    var memeModel: MemeModel! = nil
    var textFieldAttributes = [NSAttributedString.Key: Any]() // Contains all the text customizations
    var photoTaken: Bool = false // True if a photo was taken during photo picker
    var editorState: MemeEditorState = .WaitingForImage // State of editor
    
    // An enum to identify buttons based on their tag property in Interface Builder
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
    
    func getMemedImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(memeView.bounds.size, false, 0)
        memeView.drawHierarchy(in: memeView.bounds, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
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
    
    func save(withMemedImage memedImage: UIImage) {
        memeModel.memedImage = memedImage
        memeModel.topText = topTextField.text
        memeModel.bottomText = bottomTextField.text
        
        // Add to the memes array in the application delegate
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(memeModel)
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveMeme(_ sender: UIBarButtonItem) {
        guard let memedImage = getMemedImage() else {
            assert(false, "Failed to grab screenshot of memed image")
        }
        
        var activityView: UIActivityViewController
        if photoTaken {
            // if camera chosen, then save both unmemed and memed images
            activityView = UIActivityViewController(activityItems: [memeModel.originalImage, memedImage], applicationActivities: nil)
        } else {
            // if album chosen, save only memed image
            activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        }
        
        // Handle the activity view
        activityView.completionWithItemsHandler = { (activityType: UIActivity.ActivityType?, success: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if success {
                self.save(withMemedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("ActivityView cancelled")
            }
        }
        
        // open action sheet
        present(activityView, animated: true, completion: nil)
    }
}

// MARK: State Management

extension MemeEditorViewController {
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
            
            // Enable share button
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
            
            // Disable the share button
            shareButton.isEnabled = false
        }
    }
}

// MARK: Delegate Functions

extension MemeEditorViewController {
    
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
