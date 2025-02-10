//
//  CommentRequest.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import Foundation

struct CommentRequest: Codable {
    let videoId: Int
    let comment: String
    let startingPoint: Int?
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case comment = "comment"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(videoId.toString(), forKey: .videoId)
        if !comment.isEmpty {
            try container.encode(comment, forKey: .comment)
        }
        if let startingPoint = startingPoint {
            try container.encode(startingPoint, forKey: .startingPoint)
        }
    }
}

struct PostCommentRequest: Codable {
    let userId: Int
    let videoId: Int
    let comment: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case videoId = "video_id"
        case comment = "comment"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId.toString(), forKey: .userId)
        try container.encode(videoId.toString(), forKey: .videoId)
        if !comment.isEmpty {
            try container.encode(comment, forKey: .comment)
        }
    }
}

struct PostCommentReplyRequest: Codable {
    let comment: String
    let commentId: Int
    let videoId: Int
    
    enum CodingKeys: String, CodingKey {
        case comment = "comment"
        case commentId = "parent_id"
        case videoId   = "video_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if !comment.isEmpty {
            try container.encode(comment, forKey: .comment)
        }
        try container.encode(commentId.toString(), forKey: .commentId)
        try container.encode(videoId.toString(), forKey: .videoId)
    }
}

struct LikeReplyCommentsRequest: Codable {
    let commentReplyId: Int
    
    enum CodingKeys: String, CodingKey {
        case commentReplyId = "comment_reply_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(commentReplyId.toString(), forKey: .commentReplyId)
    }
}
