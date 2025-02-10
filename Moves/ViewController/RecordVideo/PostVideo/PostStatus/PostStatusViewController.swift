//
//  PostStatusViewController.swift
// //
//
//  Created by iMac on 12/06/2024.
//

import UIKit

class PostStatusViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var lbl = ""
    var status = ""
    var selected = ""
    var mainArr: [String] = []
    var callback: ((_ str: String, _ status: String) -> Void)?
    
    @IBOutlet var lblOption: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblOption.text = lbl
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "PostStatusTableViewCell", bundle: nil), forCellReuseIdentifier: "PostStatusTableViewCell")
        tableView.rowHeight = 40
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if touch.view == view {
                dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mainArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostStatusTableViewCell", for: indexPath) as! PostStatusTableViewCell
        let postText = mainArr[indexPath.row]
        cell.lblPost.text = postText
        
        if postText == selected {
            cell.accessoryType = .none
            if cell.accessoryView == nil {
                let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))
                checkmark.tintColor = UIColor.appColor(.theme)
                cell.accessoryView = checkmark
            }
        } else {
            cell.accessoryView = nil
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let text = mainArr[indexPath.row]
        callback?(text, status)
        dismiss(animated: false)
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: false)
    }
}
