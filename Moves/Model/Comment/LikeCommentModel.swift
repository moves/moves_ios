//
//  LikeCommentModel.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import Foundation

struct LikeCommentResponse: Codable {
    let code: Int
    var msg: LikeCommentResponseMsg?
    let likeCount: Int
    let errorMessage: String?

        enum CodingKeys: String, CodingKey {
            case code, msg
            case likeCount = "like_count"
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            code = try container.decode(Int.self, forKey: .code)
            likeCount = try container.decode(Int.self, forKey: .likeCount)
            
            if code == 200 {
                if let msgArray = try? container.decode(LikeCommentResponseMsg.self, forKey: .msg) {
                    msg = msgArray
                    errorMessage = nil
                } else if let msgString = try? container.decode(String.self, forKey: .msg) {
                    msg = nil
                    errorMessage = msgString
                } else {
                    msg = nil
                    errorMessage = "Unexpected format for msg"
                }
            } else {
                msg = nil
                errorMessage = try? container.decode(String.self, forKey: .msg)
            }
        }
}

// MARK: - Msg
struct LikeCommentResponseMsg: Codable {
    let videoCommentLike: VideoCommentLike
    let videoComment: VideoComment
    let user: User

    enum CodingKeys: String, CodingKey {
        case videoCommentLike = "VideoCommentLike"
        case videoComment = "VideoComment"
        case user = "User"
    }
}

struct VideoCommentLike: Codable {
    let id, userID, commentID: Int
    let created: String
    let ownerLike: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case commentID = "comment_id"
        case created
        case ownerLike = "owner_like"
    }
}

