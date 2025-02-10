//
//  CommentRowTableViewCell.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import UIKit

class CommentRowTableViewCell: UITableViewCell {

    @IBOutlet weak var lblCommentCount: UILabel!
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var lblComment: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgProfile: CustomImageView!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var moreReplyView: UIView!
    @IBOutlet weak var btnViewMoreReply: UIButton!
    
    @IBOutlet weak var btnLargeLike: UIButton!
    
}
