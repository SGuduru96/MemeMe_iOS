//
//  TableViewController.swift
//  MemeMe
//
//  Created by Sunny Guduru on 9/12/19.
//  Copyright © 2019 Sunny Guduru. All rights reserved.
//

import UIKit

class SentMemesTableViewController: UITableViewController {
    
    // MARK: Properties
    
    let cellReuseIdentifier = "MemeCellIdentifier"
    
    var memes: [MemeModel]! {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.memes
    }
    
    var tableState: State {
        get {
            return tableView!.isEditing ? State.Editing : State.Normal
        }
        
        // Set the tableView to isEditing and then call updateEditButtonState
        set(newState) {
            switch newState {
            case .Editing:
                tableView.isEditing = true
            case .Normal:
                tableView.isEditing = false
            }
            
            updateEditButtonState()
        }
    }
    
    // MARK: View Controller Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Enable edit button on the left side of navigation bar
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Set tableState
        tableState = .Normal
        
        // Reload data
        tableView.reloadData()
    }
}

// MARK: Data Source and Table View Delegate

extension SentMemesTableViewController {
    // MARK: - Table view data source
    // Get number of rows in section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    // Get cell for a row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        // Configure cell with image and text
        cell.imageView?.image = memes[indexPath.row].memedImage
        cell.textLabel?.text = memes[indexPath.row].description
        
        return cell
    }
    
    // Edit or Insert cells in editing view
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        if editingStyle == .delete {
            // Delete the row from the data source
            appDelegate.memes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Disable editing if there are no rows left
            if memes.count <= 0 {
                tableState = .Editing
            }
        }
    }
    
    // Cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        // Confgiure detail view with memeImage and title
        let meme = memes[indexPath.row]
        detailVC.memeImage = meme.memedImage!
        detailVC.title = meme.description
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}

// MARK: State Management

extension SentMemesTableViewController {
    enum State: Int {
        case Editing = 0
        case Normal = 1
    }
    
    // Update edit button based on tableState
    func updateEditButtonState() {
        if memes.count <= 0 {
            // No rows to edit
            // Before disabling the button lets set it back to "Edit"
            if editButtonItem.title == "Done" {
                let _ = editButtonItem.target?.perform(editButtonItem.action!)
            }
            
            // Disable button
            editButtonItem.isEnabled = false
        } else {
            // Enable button since there are rows to edit
            editButtonItem.isEnabled = true
        }
    }
}
