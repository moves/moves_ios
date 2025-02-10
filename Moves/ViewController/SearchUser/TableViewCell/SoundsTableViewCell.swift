//
//  SoundsTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 19/05/2024.
//

import UIKit
class SoundsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSoundName: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var soundImage: CustomImageView!
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var btnVideo: CustomButton!
    @IBOutlet weak var btnHashtag: CustomButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
