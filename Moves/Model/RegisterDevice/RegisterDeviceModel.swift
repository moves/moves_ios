//
//  RegisterDeviceModel.swift
// //
//
//  Created by Wasiq Tayyab on 10/05/2024.
//

import Foundation

// MARK: - RegisterDeviceResponse
struct RegisterDeviceResponse: Codable {
    let code: Int
    let msg: RegisterDeviceResponseMsg
}

// MARK: - Msg
struct RegisterDeviceResponseMsg: Codable {
    let device: Device

    enum CodingKeys: String, CodingKey {
        case device = "Device"
    }
}

// MARK: - Device
struct Device: Codable {
    let id: Int
    let key, created: String
}

