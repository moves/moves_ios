//
//  PurchaseCoinResponse.swift
//  Moves
//
//  Created by Wasiq Tayyab on 19/10/2024.
//

import Foundation
// MARK: - RepostVideoResponse
struct PurchaseCoinResponse: Codable {
    let code: Int
    var msg: PurchaseCoinResponseMsg?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case code, msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)

        if code == 200 {
            msg = try? container.decode(PurchaseCoinResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct PurchaseCoinResponseMsg: Codable {
    let purchaseCoin: PurchaseCoin
    let user: HomeUser

    enum CodingKeys: String, CodingKey {
        case purchaseCoin = "PurchaseCoin"
        case user = "User"
    }
}

// MARK: - PurchaseCoin
struct PurchaseCoin: Codable {
    let id, userID: Int
    let title: String
    let coin, price: Int
    let transactionID, device, created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case title, coin, price
        case transactionID = "transaction_id"
        case device, created
    }
}


// MARK: - CoinWorthResponse
struct CoinWorthResponse: Codable {
    let code: Int
    var msg: CoinWorthResponseMsg?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case code, msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)

        if code == 200 {
            msg = try? container.decode(CoinWorthResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct CoinWorthResponseMsg: Codable {
    let coinWorth: CoinWorth

    enum CodingKeys: String, CodingKey {
        case coinWorth = "CoinWorth"
    }
}

// MARK: - CoinWorth
struct CoinWorth: Codable {
    let id: Int
    let price: Double
}
