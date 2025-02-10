//
//  SearchRequest.swift
// //
//
//  Created by Wasiq Tayyab on 21/05/2024.
//

import Foundation

struct SearchRequest: Codable {
    let userId: String
    let type: String
    let keyword: String
    let startingPoint: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case type = "type"
        case keyword = "keyword"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(type, forKey: .type)
        try container.encode(keyword, forKey: .keyword)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
}

struct ShowStoreRequest: Codable {
    let userId: String
    let keyword: String
    let startingPoint: Int
    let deliveryAddressId: Int
    let lat: Double
    let long: Double
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case keyword = "keyword"
        case startingPoint = "starting_point"
        case deliveryAddressId = "delivery_address_id"
        case long = "long"
        case lat = "lat"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(keyword, forKey: .keyword)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
        try container.encode(deliveryAddressId.toString(), forKey: .deliveryAddressId)
        try container.encode(lat.toString(), forKey: .lat)
        try container.encode(long.toString(), forKey: .long)
    }
}

