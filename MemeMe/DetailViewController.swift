//
//  DetailViewController.swift
//  MemeMe
//
//  Created by Sunny Guduru on 9/14/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    // MARK: Properties
    var memeImage = UIImage()
    
    // MARK: Outlets
    @IBOutlet weak var memeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any ad2ditional setup after loading the view.
        memeImageView.image = memeImage
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
