//
//  AddVideoFavouriteModel.swift
// //
//
//  Created by Wasiq Tayyab on 27/06/2024.
//

import Foundation

// MARK: - AddVideoFavouriteResponse
struct AddVideoFavouriteResponse: Codable {
    let code: Int
    var msg: AddVideoFavouriteResponseMsg?
    let errorMessage: String?
    let favCount: Int
    
    enum CodingKeys: String, CodingKey {
        case code, msg
        case favCount = "fav_count"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        favCount = try container.decode(Int.self, forKey: .favCount)
        if code == 200 {
            msg = try container.decode(AddVideoFavouriteResponseMsg.self, forKey: .msg)
            errorMessage = nil
        } else {
            msg = nil
            errorMessage = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct AddVideoFavouriteResponseMsg: Codable {
    let videoFavourite: VideoFavourite
    let video: Video
    let user: User

    enum CodingKeys: String, CodingKey {
        case videoFavourite = "VideoFavourite"
        case video = "Video"
        case user = "User"
    }
}
