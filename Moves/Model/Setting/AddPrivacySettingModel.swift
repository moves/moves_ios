//
//  AddPrivacySettingModel.swift
// //
//
//  Created by Wasiq Tayyab on 28/06/2024.
//

import Foundation

// MARK: - AddPrivacySettingResponse
struct AddPrivacySettingResponse: Codable {
    let code: Int
    let msg: AddPrivacySettingResponseMsg
}

// MARK: - Msg
struct AddPrivacySettingResponseMsg: Codable {
    let privacySetting: PrivacySetting
    let user: User

    enum CodingKeys: String, CodingKey {
        case privacySetting = "PrivacySetting"
        case user = "User"
    }
}
