//
//  SettingRequest.swift
// //
//
//  Created by Wasiq Tayyab on 24/06/2024.
//

import Foundation

struct SettingRequest: Codable {
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
    }
}

struct ShowBlockedUsersRequest: Codable {
    let userId: String
    let startingPoint: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case startingPoint = "starting_point"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(startingPoint.toString(), forKey: .startingPoint)
    }
}

struct BlockUserRequest: Codable {
    let userId: String
    let blockUserId: String
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case blockUserId = "block_user_id"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(blockUserId, forKey: .blockUserId)
    }
}

struct UserVerificationRequest: Codable {
    let userId: String
    let name: String
    let attachment: Attachment
    
    struct Attachment: Codable {
        let fileData: String
        
        enum CodingKeys: String, CodingKey {
            case fileData = "file_data"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case name
        case attachment
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encode(attachment, forKey: .attachment)
    }
}

struct EditProfileRequest: Codable {
    let firstName: String?
    let lastName: String?
    let gender: String?
    let website: String?
    let bio: String?
    let phone: String?
    let email: String?
    let username: String?
    let profileImage: String?
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case gender
        case website
        case bio
        case phone
        case email
        case username
        case profileImage = "profile_pic"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if let firstName = firstName {
            try container.encode(firstName, forKey: .firstName)
        }
        if let lastName = lastName {
            try container.encode(lastName, forKey: .lastName)
        }
        if let gender = gender {
            try container.encode(gender, forKey: .gender)
        }
        if let website = website {
            try container.encode(website, forKey: .website)
        }
        if let bio = bio {
            try container.encode(bio, forKey: .bio)
        }
        if let phone = phone {
            try container.encode(phone, forKey: .phone)
        }
        if let email = email {
            try container.encode(email, forKey: .email)
        }
        if let username = username {
            try container.encode(username, forKey: .username)
        }
        if let profileImage = profileImage {
            try container.encode(profileImage, forKey: .profileImage)
        }
    }
}


struct DeleteUserAccountRequest: Codable {
    let authToken: String
  
    enum CodingKeys: String, CodingKey {
        case authToken = "auth_token"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authToken, forKey: .authToken)
    }
}

struct WithdrawRequest: Codable {
    let userId: String
    let coin: String
    let amount: String
    let email: String
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case coin = "coin"
        case amount = "amount"
        case email = "email"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(coin, forKey: .coin)
        try container.encode(amount, forKey: .amount)
        try container.encode(email, forKey: .email)
    }
}

struct AddPayoutRequest: Codable {
    let userId: String
    let value: String
    let type: String
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case value = "value"
        case type = "type"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(value, forKey: .value)
        try container.encode(type, forKey: .type)
    }
}

struct PaymentRequest: Codable {
    let userId: String
    let card: String
    let cvc: String
    let expMonth: Int
    let expYear: Int
    let name: String
    let zipcode: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case card
        case cvc
        case expMonth = "exp_month"
        case expYear = "exp_year"
        case name
        case zipcode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(card, forKey: .card)
        try container.encode(cvc, forKey: .cvc)
        try container.encode(expMonth, forKey: .expMonth)
        try container.encode(expYear, forKey: .expYear)
        try container.encode(name, forKey: .name)
        try container.encode(zipcode, forKey: .zipcode)
    }
}

struct DeletePaymentRequest: Codable {
    let userId: String
    let id: Int
 
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case id
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(userId, forKey: .userId)
        try container.encode(id.toString(), forKey: .id)
    }
}
