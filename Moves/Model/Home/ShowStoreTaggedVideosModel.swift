//
//  ShowStoreTaggedVideosModel.swift
// //
//
//  Created by Wasiq Tayyab on 17/07/2024.
//

import Foundation

// MARK: - ShowStoreTaggedVideosResponse
struct ShowStoreTaggedVideosResponse: Codable {
    let code: Int
    var msg: [ShowStoreTaggedVideosResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([ShowStoreTaggedVideosResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ShowStoreTaggedVideosResponseMsg: Codable {
    let videoProduct: VideoProduct
    let video: Video
    let store: Store

    enum CodingKeys: String, CodingKey {
        case videoProduct = "VideoProduct"
        case video = "Video"
        case store = "Store"
    }
}
