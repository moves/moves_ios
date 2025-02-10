//
//  ShowSoundsAgainstSectionModel.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import Foundation

// MARK: - ShowSoundsAgainstSectionResponse
struct ShowVideosAgainstSoundResponse: Codable {
    let code: Int
    var msg: [ShowVideosAgainstSoundResponseMsg]?
    let soundFav: Int?

    enum CodingKeys: String, CodingKey {
        case code, msg
        case soundFav = "sound_fav"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        
        if code == 200 {
            msg = try container.decode([ShowVideosAgainstSoundResponseMsg].self, forKey: .msg)
        } else {
            msg = nil
        }
        soundFav = try? container.decode(Int.self, forKey: .soundFav)
    }
}

// MARK: - Msg
struct ShowVideosAgainstSoundResponseMsg: Codable {
    let video: Video
    let user: HomeUser
    let sound: Sound
    let location: HomeLocation?

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case sound = "Sound"
        case location = "Location"
    }
}

