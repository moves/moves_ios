//
//  SettingTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import UIKit

class SettingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblSetting: UILabel!
    @IBOutlet weak var imgSetting: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
