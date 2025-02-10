//
//  CommentHeaderTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import UIKit

class CommentHeaderTableViewCell: UITableViewHeaderFooterView {
    
    
    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var btnReply: UIButton!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: CustomImageView!
    
    
    @IBOutlet weak var moreReplyView: UIView!
    @IBOutlet weak var btnViewMoreReply: UIButton!
    
    @IBOutlet weak var btnLargeLike: UIButton!
    
    
}
