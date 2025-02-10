//
//  AddDeviceDataRequest.swift
// //
//
//  Created by Wasiq Tayyab on 10/05/2024.
//

import Foundation

struct AddDeviceDataRequest: Codable {
    
    let userId: String
    let device: String
    let appVersion: String
    let ip: String?
    let deviceToken: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case device = "device"
        case appVersion = "version"
        case ip = "ip"
        case deviceToken = "device_token"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(device, forKey: .device)
        try container.encode(appVersion, forKey: .appVersion)
        try container.encode(ip, forKey: .ip)
        try container.encode(deviceToken, forKey: .deviceToken)
    }
}
