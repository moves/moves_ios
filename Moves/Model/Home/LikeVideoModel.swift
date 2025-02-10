//
//  LikeVideoModel.swift
// //
//
//  Created by Wasiq Tayyab on 27/06/2024.
//

import Foundation

// MARK: - LikeVideoResponse
struct LikeVideoResponse: Codable {
    let code: Int
    var msg: LikeVideoResponseMsg?
    let like, likeCount: Int
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg, like
        case likeCount = "like_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        like = try container.decode(Int.self, forKey: .like)
        likeCount = try container.decode(Int.self, forKey: .likeCount)
        if code == 200 {
            msg = try container.decode(LikeVideoResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct LikeVideoResponseMsg: Codable {
    let videoLike: VideoLike
    let video: Video
    let user: User

    enum CodingKeys: String, CodingKey {
        case videoLike = "VideoLike"
        case video = "Video"
        case user = "User"
    }
}
