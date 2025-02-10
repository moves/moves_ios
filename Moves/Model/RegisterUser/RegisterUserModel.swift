//
//  RegisterUserModel.swift
// //
//
//  Created by Wasiq Tayyab on 12/05/2024.
//

import Foundation

// MARK: - RegisterUserResponse
struct RegisterUserResponse: Codable {
    let code: Int
    let msg: LoginMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(LoginMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}
