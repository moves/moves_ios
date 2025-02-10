//
//  VideoTypeTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 10/06/2024.
//

import UIKit
class VideoTypeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblVideoNotification: UILabel!
    @IBOutlet weak var videoProfileImage: CustomImageView!
    @IBOutlet weak var imgVideoNotification: CustomImageView!
  
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
