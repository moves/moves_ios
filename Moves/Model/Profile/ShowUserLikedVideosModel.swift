//
//  ShowUserLikedVideosModel.swift
// //
//
//  Created by Wasiq Tayyab on 14/06/2024.
//

import Foundation

// MARK: - ShowUserLikedVideosResponse
struct ShowUserLikedVideosResponse: Codable {
    let code: Int
    var msg: [ShowUserLikedVideosResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([ShowUserLikedVideosResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ShowUserLikedVideosResponseMsg: Codable {
    let videoLike: VideoUserLike
    let video: Video

    enum CodingKeys: String, CodingKey {
        case videoLike = "VideoLike"
        case video = "Video"
    }
}

// MARK: - VideoLike
struct VideoUserLike: Codable {
    let id, userID, videoID: Int
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case videoID = "video_id"
        case created
    }
}
