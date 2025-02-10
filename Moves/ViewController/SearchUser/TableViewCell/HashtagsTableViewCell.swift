//
//  HashtagsTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 19/05/2024.
//

import UIKit
class HashtagsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblPost: UILabel!
    @IBOutlet weak var lblHashtag: UILabel!
    @IBOutlet weak var hashtagImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
