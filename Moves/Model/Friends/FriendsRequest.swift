//
//  FriendsRequest.swift
// //
//
//  Created by Wasiq Tayyab on 15/06/2024.
//

import Foundation

struct FriendsRequest: Codable {
    let userId: String
    let startingPoint: Int
    let otherUserId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case otherUserId = "other_user_id"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        if !otherUserId.isEmpty {
            try container.encode(otherUserId, forKey: .otherUserId)
        }
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
}

struct ShowSuggestedUsersRequest: Codable {
    let userId: String
    let otherUserId: String?
    let startingPoint: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case otherUserId = "other_user_id"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(otherUserId, forKey: .otherUserId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
}



