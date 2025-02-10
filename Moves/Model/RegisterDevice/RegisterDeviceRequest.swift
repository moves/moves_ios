//
//  RegisterDeviceRequest.swift
// //
//
//  Created by Wasiq Tayyab on 10/05/2024.
//

import Foundation

struct RegisterDeviceRequest: Codable {
    
    let key: String

    enum CodingKeys: String, CodingKey {
        case key = "key"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(key, forKey: .key)
    }
}
