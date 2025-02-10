//
//  ShowVideosAgainstLocationModel.swift
// //
//
//  Created by Wasiq Tayyab on 25/06/2024.
//

import Foundation

// MARK: - ShowVideosAgainstLocationResponse
struct ShowVideosAgainstLocationResponse: Codable {
    let code: Int
    var msg: [ShowVideosAgainstLocationResponseMsg]?

    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        
        if code == 200 {
            msg = try container.decode([ShowVideosAgainstLocationResponseMsg].self, forKey: .msg)
        } else {
            msg = nil
        }
    }
}

// MARK: - Msg
struct ShowVideosAgainstLocationResponseMsg: Codable {
    let video: Video
    let user: HomeUser
    let sound: Sound
    let location: HomeLocation

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case sound = "Sound"
        case location = "Location"
    }
}
