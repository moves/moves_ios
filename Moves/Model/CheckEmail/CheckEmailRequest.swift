//
//  CheckEmailRequest.swift
// //
//
//  Created by Wasiq Tayyab on 09/05/2024.
//

import Foundation

struct CheckEmailRequest: Codable {
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case email = "email"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
    }
}
