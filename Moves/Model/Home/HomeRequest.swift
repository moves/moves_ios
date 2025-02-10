//
//  HomeRequest.swift
// //
//
//  Created by Wasiq Tayyab on 30/05/2024.
//

import Foundation

struct HomeRequest: Codable {
    let userId: String
    let deviceId: String
    let tagProduct: Int?
    let startingPoint: Int
    let deliveryAddressId: Int?
    let lat: Double
    let long: Double
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceId = "device_id"
        case tagProduct = "tag_product"
        case startingPoint = "starting_point"
        case deliveryAddressId = "delivery_address_id"
        case long = "long"
        case lat = "lat"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
        try container.encode(lat.toString(), forKey: .lat)
        try container.encode(long.toString(), forKey: .long)
        if let tagProduct = tagProduct, tagProduct != 0 {
            try container.encode(tagProduct.toString(), forKey: .tagProduct)
        }
        if let deliveryAddressId = deliveryAddressId, deliveryAddressId != 0 {
            try container.encode(deliveryAddressId.toString(), forKey: .deliveryAddressId)
        }
    }
}


struct ShowNearbyVideosRequest: Codable {
    let userId: String
    let deviceId: String
    let lat: Double
    let long: Double
    let startingPoint: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceId = "device_id"
        case long = "long"
        case lat = "lat"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(lat.toString(), forKey: .lat)
        try container.encode(long.toString(), forKey: .long)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
}

struct ShowFollowingVideosRequest: Codable {
    let userId: String
    let deviceId: String
    let startingPoint: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case deviceId = "device_id"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(deviceId, forKey: .deviceId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
    
}

struct VerifyAccountDetailsRequest: Codable {
    let type: String
    let socialId: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case socialId = "social_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(socialId, forKey: .socialId)
    }
    
}


