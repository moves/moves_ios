//
//  LocationTableViewCell.swift
// //
//
//  Created by iMac on 12/06/2024.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lblLocationName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
