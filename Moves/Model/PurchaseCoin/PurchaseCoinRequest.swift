//
//  PurchaseCoinRequest.swift
//  Moves
//
//  Created by Wasiq Tayyab on 19/10/2024.
//

import Foundation

struct PurchaseCoinRequest: Codable {
    let userId: String
    let coin: String
    let title: String
    let price: String
    let transactionId: String
    let device: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case coin
        case title
        case price
        case transactionId = "transaction_id"
        case device
    }
}
