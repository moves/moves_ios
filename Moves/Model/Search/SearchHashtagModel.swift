//
//  SearchHashtagModel.swift
// //
//
//  Created by Wasiq Tayyab on 23/05/2024.
//

import Foundation

// MARK: - SearchHashtagResponse
struct SearchHashtagResponse: Codable {
    let code: Int
    var msg: [SearchHashtagMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([SearchHashtagMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct SearchHashtagMsg: Codable {
    let hashtag: Hashtag

    enum CodingKeys: String, CodingKey {
        case hashtag = "Hashtag"
    }
}

// MARK: - Hashtag
struct Hashtag: Codable {
    let id: Int
    let name: String
    let videosCount: Int
    let views: String?
    let favourite: Int

    enum CodingKeys: String, CodingKey {
        case id, name
        case videosCount = "videos_count"
        case views, favourite
    }
}
