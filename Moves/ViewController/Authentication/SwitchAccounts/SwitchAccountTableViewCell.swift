//
//  SwitchAccountTableViewCell.swift
//  Infotex
//
//  Created by Wasiq Tayyab on 14/09/2021.
//

import UIKit

class SwitchAccountTableViewCell: UITableViewCell {
    
    //MARK:- Outlets
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblName: UILabel!
    
    
    //MARK: AwakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
