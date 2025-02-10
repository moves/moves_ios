//
//  RegisterUserRequest.swift
// //
//
//  Created by Wasiq Tayyab on 12/05/2024.
//

import Foundation

struct RegisterUserAppRequest: Codable {
    let username: String
    let dob: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let socialID: String
    let authToken: String
    let deviceToken: String
    let socialType: String
    
    enum CodingKeys: String, CodingKey {
        case dob
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case socialID = "social_id"
        case authToken = "auth_token"
        case deviceToken = "device_token"
        case socialType = "social"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        if !dob.isEmpty {
            try container.encode(dob, forKey: .dob)
        }
        if !username.isEmpty {
            try container.encode(username, forKey: .username)
        }
        if !firstName.isEmpty {
            try container.encode(firstName, forKey: .firstName)
        }
        if !lastName.isEmpty {
            try container.encode(lastName, forKey: .lastName)
        }
        if !email.isEmpty {
            try container.encode(email, forKey: .email)
        }
        if !phone.isEmpty {
            try container.encode(phone, forKey: .phone)
        }
        if !socialID.isEmpty {
            try container.encode(socialID, forKey: .socialID)
        }
        if !authToken.isEmpty {
            try container.encode(authToken, forKey: .authToken)
        }
        if !deviceToken.isEmpty {
            try container.encode(deviceToken, forKey: .deviceToken)
        }
        if !socialType.isEmpty {
            try container.encode(socialType, forKey: .socialType)
        }
    }
}

struct RegisterShopAppRequest: Codable {
    let username: String
    let dob: String
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let socialID: String
    let authToken: String
    let deviceToken: String
    let socialType: String
    
    let lat: String
    let long: String
    let storeName: String
    let storeType: String
    let aptSuite: String
    let companyName: String
    
    enum CodingKeys: String, CodingKey {
        case dob
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case email
        case phone
        case socialID = "social_id"
        case authToken = "auth_token"
        case deviceToken = "device_token"
        case socialType = "social"
        case lat
        case long
        case storeName = "store_name"
        case storeType = "store_type"
        case aptSuite = "apt_suite"
        case companyName = "company_name"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dob, forKey: .dob)
        try container.encode(username, forKey: .username)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(socialID, forKey: .socialID)
        try container.encode(authToken, forKey: .authToken)
        try container.encode(deviceToken, forKey: .deviceToken)
        try container.encode(socialType, forKey: .socialType)
        
        try container.encode(lat, forKey: .lat)
        try container.encode(long, forKey: .long)
        try container.encode(storeName, forKey: .storeName)
        try container.encode(storeType, forKey: .storeType)
        try container.encode(aptSuite, forKey: .aptSuite)
        try container.encode(companyName, forKey: .companyName)
    }
}
