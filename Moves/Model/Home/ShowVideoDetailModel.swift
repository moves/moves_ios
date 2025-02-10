//
//  ShowVideoDetailModel.swift
// //
//
//  Created by Wasiq Tayyab on 27/06/2024.
//

import Foundation

// MARK: - ShowVideoDetailResponse
struct ShowVideoDetailResponse: Codable {
    let code: Int
    var msg: ShowVideoDetailResponseMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(ShowVideoDetailResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
    
}


// MARK: - Msg
struct ShowVideoDetailResponseMsg: Codable {
    let video: Video?
    let user: HomeUser?
    let store: Store?
    let videoComment: [VideoComment]?
    let videoProduct: [VideoProduct]?

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case store = "Store"
        case videoComment = "VideoComment"
        case videoProduct = "VideoProduct"
    }

    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(store, forKey: .store)
        try container.encodeIfPresent(videoComment, forKey: .videoComment)
        try container.encodeIfPresent(videoProduct, forKey: .videoProduct)
    }

    // Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        video = try container.decodeIfPresent(Video.self, forKey: .video)
        user = try container.decodeIfPresent(HomeUser.self, forKey: .user)
        store = try container.decodeIfPresent(Store.self, forKey: .store)
        videoComment = try container.decodeIfPresent([VideoComment].self, forKey: .videoComment)
        videoProduct = try container.decodeIfPresent([VideoProduct].self, forKey: .videoProduct)
    }
}
