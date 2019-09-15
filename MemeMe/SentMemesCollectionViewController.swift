//
//  CollectionViewController.swift
//  MemeMe
//
//  Created by Sunny Guduru on 9/14/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import UIKit

class SentMemesCollectionViewController: UICollectionViewController {
    
    
    // MARK: Properties
    
    let reuseIdentifier = "MemeCell"
    
    var memes: [MemeModel]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    // MARK: Oulets
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space: CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Reload data incase some cells were deleted in tableView
        collectionView.reloadData()
    }
}

// MARK: Delegate Methods

extension SentMemesCollectionViewController {
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MemeCollectionViewCell
        
        // Configure the cell
        let meme = memes[indexPath.row]
        cell.memeImageView?.image = meme.memedImage
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    // Cell is selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        // Confgiure detail view with memeImage and title
        let meme = memes[indexPath.row]
        detailVC.memeImage = meme.memedImage!
        detailVC.title = meme.description
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}
