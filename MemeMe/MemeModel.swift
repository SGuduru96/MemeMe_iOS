//
//  MemeModel.swift
//  MemeMe
//
//  Created by Sunny Guduru on 8/24/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import Foundation
import UIKit

struct MemeModel {
    var topText: String?
    var bottomText: String?
    var originalImage: UIImage
    var memedImage: UIImage?
    
    init(image: UIImage, topText: String? = nil, bottomText: String? = nil) {
        self.originalImage = image
        self.topText = topText
        self.bottomText = bottomText
    }
}
