//
//  MemeModel.swift
//  MemeMe
//
//  Created by Sunny Guduru on 8/24/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import Foundation
import UIKit

struct MemeModel: CustomStringConvertible {
    var topText: String?
    var bottomText: String?
    var originalImage: UIImage
    var memedImage: UIImage?
    
    // Custom String Convertable Porotocl Method
    var description: String {
        var text = ""
        if topText != nil {
            text += topText! + " "
        }
        if bottomText != nil {
            text += bottomText! + " "
        }

        return text
    }
    
    init(image: UIImage, topText: String? = nil, bottomText: String? = nil) {
        self.originalImage = image
        self.topText = topText
        self.bottomText = bottomText
    }
}
