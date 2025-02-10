//
//  VideoProfileCollectionViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 13/06/2024.
//

import UIKit
import SkeletonView
class VideoProfileCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var lblView: UILabel!
    @IBOutlet weak var videoView: UIImageView!
    
    @IBOutlet weak var imgplay: UIImageView!
    @IBOutlet weak var pinnedview: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

}
