//
//  LikeCommentRequest.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import Foundation

struct LikeCommentRequest: Codable {
    let commentId: Int
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case commentId = "comment_id"
        case userId = "user_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(commentId.toString(), forKey: .commentId)
        try container.encode(userId, forKey: .userId)
    }
}
