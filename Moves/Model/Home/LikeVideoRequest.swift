//
//  LikeVideoRequest.swift
// //
//
//  Created by Wasiq Tayyab on 27/06/2024.
//

import Foundation

struct LikeVideoRequest: Codable {
    let userId: String
    let videoId: Int
 
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case videoId = "video_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(videoId.toString(), forKey: .videoId)
    }
}
