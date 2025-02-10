//
//  DiscoverRequest.swift
// //
//
//  Created by Wasiq Tayyab on 04/06/2024.
//

import Foundation

struct DiscoverRequest: Codable {
    let userId: String
    let countryId: String
    let startingPoint: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case countryId = "country_id"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(countryId, forKey: .countryId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
}
