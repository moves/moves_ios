//
//  SendNotificationRequest.swift
// //
//
//  Created by Wasiq Tayyab on 30/06/2024.
//

import Foundation

struct SendNotificationRequest: Codable {
    let senderId: String
    let receiverId: String
    let title: String
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case title = "title"
        case message = "message"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(senderId, forKey: .senderId)
        try container.encode(receiverId, forKey: .receiverId)
        try container.encode(title, forKey: .title)
        try container.encode(message, forKey: .message)
    }
}
