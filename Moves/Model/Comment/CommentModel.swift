//
//  CommentModel.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import Foundation

struct CommentResponse: Codable {
    let code: Int
    var msg: [CommentResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([CommentResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct CommentResponseMsg: Codable {
    var videoComment: VideoComment
    let video: Video?
    let user: HomeUser
    var videoCommentReply: [CommentResponseMsg]?
    var collapsed: Bool?

    enum CodingKeys: String, CodingKey {
        case videoComment = "VideoComment"
        case video = "Video"
        case user = "User"
        case videoCommentReply = "Children" //"VideoCommentReply"
        case collapsed = "collapsed"
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        videoComment = try container.decode(VideoComment.self, forKey: .videoComment)
        video = try container.decodeIfPresent(Video.self, forKey: .video)
        user = try container.decode(HomeUser.self, forKey: .user)
        
        // Decode VideoCommentReply based on its potential types
        if let replyArray = try? container.decodeIfPresent([CommentResponseMsg].self, forKey: .videoCommentReply) {
            videoCommentReply = replyArray
        } else if let _ = try? container.decode(String.self, forKey: .videoCommentReply) {
            videoCommentReply = nil
        } else {
            throw DecodingError.dataCorruptedError(forKey: .videoCommentReply, in: container, debugDescription: "Unexpected format for VideoCommentReply")
        }
        
        collapsed = try container.decodeIfPresent(Bool.self, forKey: .collapsed)
    }
}

//MARK: - PostCommentResponse
struct PostCommentResponse: Codable {
    let code: Int
    var msg: PostCommentResponseMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(PostCommentResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct PostCommentResponseMsg: Codable {
    let videoComment: VideoComment
    let video: Video?
    let user: User
    var videoCommentReply: [VideoComment]?

    enum CodingKeys: String, CodingKey {
        case videoComment = "VideoComment"
        case video = "Video"
        case user = "User"
        case videoCommentReply = "Children" // "VideoCommentReply"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        videoComment = try container.decode(VideoComment.self, forKey: .videoComment)
        video = try container.decodeIfPresent(Video.self, forKey: .video)
        user = try container.decode(User.self, forKey: .user)
        
        // Decode videoCommentReply as an array, handling empty array case
        if let commentsArray = try? container.decodeIfPresent([VideoComment].self, forKey: .videoCommentReply) {
            videoCommentReply = commentsArray
        } else {
            videoCommentReply = []
        }
    }

}
