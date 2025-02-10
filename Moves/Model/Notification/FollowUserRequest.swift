//
//  FollowRequest.swift
// //
//
//  Created by Wasiq Tayyab on 05/06/2024.
//

import Foundation

struct FollowUserRequest: Codable {
    let senderId: Int
    let receiverId: Int
    
    enum CodingKeys: String, CodingKey {
        case senderId = "sender_id"
        case receiverId = "receiver_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(senderId.toString(), forKey: .senderId)
        try container.encode(receiverId.toString(), forKey: .receiverId)
    }
}

