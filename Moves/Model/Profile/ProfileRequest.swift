//
//  ProfileRequest.swift
// //
//
//  Created by Wasiq Tayyab on 14/06/2024.
//

import Foundation

struct ShowVideosAgainstUserIDRequest: Codable {
    let userId: String
    let startingPoint: Int
    let otherUserId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case startingPoint = "starting_point"
        case otherUserId = "other_user_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
        if otherUserId != "" {
            try container.encode(otherUserId, forKey: .otherUserId)
        }
    }
}

