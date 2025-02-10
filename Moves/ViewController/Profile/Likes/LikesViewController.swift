//
//  LikesViewController.swift
//  Movess
//
//  Created by Mac on 31/10/2022.
//

import UIKit

class LikesViewController: UIViewController {

    var username = ""
    var likes_count = ""
    
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var lblLikesDescription: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            print("likes_count",likes_count)
        if likes_count == nil || likes_count == "" {
            likes_count = "0"
        }
        self.lblLikesDescription.text = "\(username) recived a total of \(likes_count) likes across all videos"
    }
    
    @IBAction func okPressed(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    

}
