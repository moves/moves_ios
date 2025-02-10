//
//  VerifyPhoneNo.swift
//  Tankhaw
//
//  Created by Mac on 21/03/2024.
//

import Foundation

struct VerifyPhoneNoRequest: Codable {
    let phone: String
    let verify: Int
    let code: String?
    
    enum CodingKeys: String, CodingKey {
        case phone = "phone"
        case verify = "verify"
        case code = "code"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(phone, forKey: .phone)
        try container.encode(verify.toString(), forKey: .verify)
        try container.encode(code, forKey: .code)
    }
}
