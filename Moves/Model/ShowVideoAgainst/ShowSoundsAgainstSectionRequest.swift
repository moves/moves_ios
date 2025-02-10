//
//  ShowVideosAgainstSoundRequest.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import Foundation

struct ShowVideosAgainstSoundRequest: Codable {
    let userId: String
    let soundId: String
    let startingPoint: Int
    let deviceId: String
    
    enum CodingKeys: String, CodingKey {
        case soundId = "sound_id"
        case userId = "user_id"
        case startingPoint = "starting_point"
        case deviceId = "device_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(soundId, forKey: .soundId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
        try container.encode(deviceId, forKey: .deviceId)
    }
}

struct ShowSoundsRequest: Codable {
    let userId: String
    let startingPoint: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
}


struct addFvrtSoundsRequest: Codable {
    let userId: String
    let sound_id: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case sound_id = "sound_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(sound_id, forKey: .sound_id)
    }
}
