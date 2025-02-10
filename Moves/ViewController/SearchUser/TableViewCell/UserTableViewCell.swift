//
//  UserTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 19/05/2024.
//

import UIKit
import SkeletonView
class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var btnFollow: CustomButton!
    @IBOutlet weak var lblFollowers: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgVerified: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var profileImage: CustomImageView!
    
    @IBOutlet weak var btnFollow1: CustomButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnCancel1: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
