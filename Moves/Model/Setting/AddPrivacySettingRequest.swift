//
//  AddPrivacySettingRequest.swift
// //
//
//  Created by Wasiq Tayyab on 28/06/2024.
//

import Foundation

struct AddPrivacySettingRequest: Codable {
    let authToken: String
    let videosDownload: Int?
    let directMessage: String?
    let duet: String?
    let likedVideos: String?
    let videoComment: String?
    let orderHistory: Int?
    
    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
        case videosDownload = "videos_download"
        case directMessage = "direct_message"
        case duet = "duet"
        case likedVideos = "liked_videos"
        case videoComment = "video_comment"
        case orderHistory = "order_history"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authToken, forKey: .authToken)
        try container.encode(videosDownload?.toString(), forKey: .videosDownload)
        try container.encode(directMessage, forKey: .directMessage)
        try container.encode(duet, forKey: .duet)
        try container.encode(likedVideos, forKey: .likedVideos)
        try container.encode(videoComment, forKey: .videoComment)
        try container.encode(orderHistory?.toString(), forKey: .orderHistory)
    }
}
