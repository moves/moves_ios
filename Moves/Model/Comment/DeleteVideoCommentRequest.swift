//
//  DeleteVideoCommentRequest.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import Foundation

struct DeleteVideoCommentRequest: Codable {
    let id: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.toString(), forKey: .id)
    }
}
