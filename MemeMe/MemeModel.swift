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
    
    // default init with image only required
    init(image: UIImage, topText: String? = nil, bottomText: String? = nil) {
        self.originalImage = image
        self.topText = topText
        self.bottomText = bottomText
    }
}
//
//func testModel() {
//    let gradImage = UIImage(named: "graduation")!
//    let meme = MemeModel(image: gradImage)
//    var test1 = meme.bottomText == nil
//    var test2 = meme.topText == nil
//    var test3 = meme.image == gradImage
//    assert(test1, "meme.bottomText should be nil not \(meme.bottomText)")
//    assert(test2, "meme.topText should be nil not \(meme.topText)")
//    assert(test3, "meme.image does not match gradImage.")
//    print("Init with image test passed")
//    
//    let meme2 = MemeModel(image: gradImage, topText: "What is this", bottomText: nil)
//    test2 = meme2.topText == "What is this"
//    
//    assert(test1, "meme.bottomText should be nil not \(meme.bottomText)")
//    assert(test2, "meme.bottomText should be \"What is this\" not \(test2)")
//    assert(test3, "meme.image does not match gradImage.")
//    print("init with image and top text passed")
//    
//    
//}
