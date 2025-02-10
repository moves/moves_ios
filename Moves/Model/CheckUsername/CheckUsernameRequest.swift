//
//  CheckUsernameRequest.swift
// //
//
//  Created by Wasiq Tayyab on 12/05/2024.
//

import Foundation

struct CheckUsernameRequest: Codable {
    let username: String
    
    enum CodingKeys: String, CodingKey {
        case username = "username"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(username, forKey: .username)
    }
}
