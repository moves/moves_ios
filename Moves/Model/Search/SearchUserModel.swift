//
//  SearchUserModel.swift
// //
//
//  Created by Wasiq Tayyab on 22/05/2024.
//

import Foundation

struct SearchUserResponse: Codable {
    let code: Int
    var msg: [SearchUserMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([SearchUserMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

struct SearchUserMsg: Codable {
    var user: HomeUser
    enum CodingKeys: String, CodingKey {
        case user = "User"
    }
}
