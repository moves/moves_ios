//
//  PostStatusTableViewCell.swift
// //
//
//  Created by iMac on 12/06/2024.
//

import UIKit

class PostStatusTableViewCell: UITableViewCell {

    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblDescri: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
