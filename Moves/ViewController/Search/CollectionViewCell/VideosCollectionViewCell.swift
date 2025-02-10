//
//  VideosCollectionViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 19/05/2024.
//

import UIKit
class VideosCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImage: CustomImageView!
    @IBOutlet weak var lblUsername: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblDate: UILabel!
   
    @IBOutlet weak var lblLike: UILabel!
    @IBOutlet weak var musicImage: CustomImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
