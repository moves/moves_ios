//
//  DeleteVideoRequest.swift
// //
//
//  Created by Wasiq Tayyab on 06/07/2024.
//

import Foundation

struct DeleteVideoRequest: Codable {
    let videoId: Int
   
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(videoId.toString(), forKey: .videoId)
    }
}
