//
//  ShowTaggedVideosAgainstUserIDModel.swift
// //
//
//  Created by Wasiq Tayyab on 14/06/2024.
//

import Foundation

// MARK: - ShowTaggedVideosAgainstUserIDResponse
struct ShowTaggedVideosAgainstUserIDResponse: Codable {
    let code: Int
    var msg: [ShowTaggedVideosAgainstUserIDMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([ShowTaggedVideosAgainstUserIDMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ShowTaggedVideosAgainstUserIDMsg: Codable {
    let video: Video
    let user: HomeUser
    let sound: Sound
    let location: HomeLocation
    let videoProduct: [VideoProduct]

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case sound = "Sound"
        case videoProduct = "VideoProduct"
        case location = "Location"
    }
}

// MARK: - PlaylistVideo
struct PlaylistVideo: Codable {
    let id: Int?
}
