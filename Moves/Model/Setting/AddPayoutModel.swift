//
//  AddPayoutModel.swift
// //
//
//  Created by Wasiq Tayyab on 10/07/2024.
//

import Foundation
// MARK: - AddPayoutResponse
struct AddPayoutResponse: Codable {
    let code: Int
    let msg: AddPayoutResponseMsg
}

// MARK: - Msg
struct AddPayoutResponseMsg: Codable {
    let payout: Payout
    let user: HomeUser

    enum CodingKeys: String, CodingKey {
        case payout = "Payout"
        case user = "User"
    }
}

// MARK: - Payout
struct Payout: Codable {
    let id, userID: Int
    let type, value, created: String
    let primary: Int

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case type, value, created, primary
    }
}
