//
//  ShowVideosAgainst.swift
// //
//
//  Created by Wasiq Tayyab on 19/06/2024.
//

import Foundation

struct ShowVideosAgainstHashtagRequest: Codable {
    let userId: String
    let startingPoint: Int
    let hashtag: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case startingPoint = "starting_point"
        case hashtag = "hashtag"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
        try container.encode(hashtag, forKey: .hashtag)
    }
}

