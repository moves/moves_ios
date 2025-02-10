//
//  FollowTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 10/06/2024.
//

import UIKit
class FollowTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblFollowNotification: UILabel!
    @IBOutlet weak var profileImage: CustomImageView!
    @IBOutlet weak var btnFollow: CustomButton!
    
    @IBOutlet weak var btnFollow1: UIButton!
    
    
    var shimmeringAnimatedItems: [UIView] {
        [
            lblFollowNotification,
            profileImage,
            btnFollow
        ]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
