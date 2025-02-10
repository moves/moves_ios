//
//  ShowVideosAgainstLocationRequest.swift
// //
//
//  Created by Wasiq Tayyab on 25/06/2024.
//

import Foundation

struct ShowVideosAgainstLocationRequest: Codable {
    let userId: String
    let startingPoint: Int
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case startingPoint = "starting_point"
        case id = "location_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
        try container.encode(id.toString(), forKey: .id)
    }
}

