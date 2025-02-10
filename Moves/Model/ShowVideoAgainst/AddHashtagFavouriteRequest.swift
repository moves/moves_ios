//
//  AddHashtagFavouriteRequest.swift
// //
//
//  Created by Wasiq Tayyab on 19/06/2024.
//

import Foundation

struct AddHashtagFavouriteRequest: Codable {
    let userId: String
    let hashtagId: String
    
    enum CodingKeys: String, CodingKey {
        case hashtagId = "hashtag_id"
        case userId = "user_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(hashtagId, forKey: .hashtagId)
    }
}


