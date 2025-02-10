//
//  AddInterestsModel.swift
// //
//
//  Created by YS on 2024/9/3.
//


import Foundation

struct AddInterestsResponse: Codable {
    let code: Int
    let msg: Message?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(Message.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

struct Message: Codable {
    let card: [Card]
    let deliveryAddress: [DeliveryAddress]
    let privacySetting: PrivacySetting
    let pushNotification: PushNotification
    let store: Store
    let user: User
    
    enum CodingKeys: String, CodingKey {
        case card = "Card"
        case deliveryAddress = "DeliveryAddress"
        case privacySetting = "PrivacySetting"
        case pushNotification = "PushNotification"
        case store = "Store"
        case user = "User"
    }
}
