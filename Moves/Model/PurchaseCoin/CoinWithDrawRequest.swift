//
//  CoinWithDrawRequest.swift
//  Moves
//
//  Created by Wasiq Tayyab on 19/10/2024.
//

import Foundation

struct CoinWithDrawRequest: Codable {
    let userId: String
    let amount: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case amount
    }
}
