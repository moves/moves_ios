//
//  SearchSoundResponse.swift
// //
//
//  Created by Wasiq Tayyab on 23/05/2024.
//

import Foundation

// MARK: - SearchSoundResponse
struct SearchSoundResponse: Codable {
    let code: Int
    var msg: [SearchSoundMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([SearchSoundMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct SearchSoundMsg: Codable {
    let sound: Sound
    let soundSection: SoundSection
    
    enum CodingKeys: String, CodingKey {
        case sound = "Sound"
        case soundSection = "SoundSection"
    }
}

// MARK: - SoundSection
struct SoundSection: Codable {
    let id: Int?
    let name: String?
}
