//
//  SliderModel.swift
// //
//
//  Created by Wasiq Tayyab on 04/06/2024.
//

import Foundation

// MARK: - SliderResponse
struct SliderResponse: Codable {
    let code: Int
    var msg: [SliderResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([SliderResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct SliderResponseMsg: Codable {
    let appSlider: AppSlider

    enum CodingKeys: String, CodingKey {
        case appSlider = "AppSlider"
    }
}

// MARK: - AppSlider
struct AppSlider: Codable {
    let id, image: String
    let url: String
    let ecommerce: String
}
