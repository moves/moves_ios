//
//  LoginRequest.swift
// //
//
//  Created by Wasiq Tayyab on 09/05/2024.
//

import Foundation

struct ShowUserDetailRequest: Codable {
    let authToken: String
    
    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authToken, forKey: .authToken)
    }
}

struct ShowUserOtherDetailRequest: Codable {
    let userId: String
    let otherUserId: String?
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case otherUserId = "other_user_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(otherUserId, forKey: .otherUserId)
    }
}

