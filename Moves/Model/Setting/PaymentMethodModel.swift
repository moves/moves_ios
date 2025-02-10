//
//  PaymentMethodModel.swift
// //
//
//  Created by Wasiq Tayyab on 21/07/2024.
//

import Foundation

// MARK: - PaymentMethodResponse
struct PaymentMethodResponse: Codable {
    let code: Int
    var msg: [PaymentMethodResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([PaymentMethodResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
    
}


struct CardMethodResponse: Codable {
    let code: Int
    var msg: PaymentMethodResponseMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(PaymentMethodResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
    
}

// MARK: - Msg
struct PaymentMethodResponseMsg: Codable {
    let card: Card

    enum CodingKeys: String, CodingKey {
        case card = "Card"
    }
}

// MARK: - Card
struct Card: Codable, Equatable {
    let id: Int
    let card: String
    let userID, last4: Int
    let brand: String
    let expMonth, expYear: Int
    let cardID, paymentMethodID: String
    let cardDefault, mealme: Int
    let email, created: String

    enum CodingKeys: String, CodingKey {
        case id, card
        case userID = "user_id"
        case last4 = "last_4"
        case brand
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case cardID = "card_id"
        case paymentMethodID = "payment_method_id"
        case cardDefault = "default"
        case mealme, email, created
    }
}
