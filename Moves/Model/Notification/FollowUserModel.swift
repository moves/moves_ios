//
//  FollowUserModel.swift
// //
//
//  Created by Wasiq Tayyab on 05/06/2024.
//

import Foundation

// MARK: - FollowUserReponse
struct FollowUserReponse: Codable, Equatable {
    let code: Int
    var msg: FollowUserReponseMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(FollowUserReponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct FollowUserReponseMsg: Codable, Equatable {
    let user: HomeUser
    let pushNotification: PushNotification
    let privacySetting: PrivacySetting
    let playlist: [Playlist]?
    
    enum CodingKeys: String, CodingKey {
        case user = "User"
        case pushNotification = "PushNotification"
        case privacySetting = "PrivacySetting"
        case playlist = "Playlist"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.user = try container.decode(HomeUser.self, forKey: .user)
        self.pushNotification = try container.decode(PushNotification.self, forKey: .pushNotification)
        self.privacySetting = try container.decode(PrivacySetting.self, forKey: .privacySetting)
        
        // Decode playlist
        if let playlistArray = try? container.decodeIfPresent([Playlist].self, forKey: .playlist) {
            self.playlist = playlistArray
        } else if let _ = try? container.decodeIfPresent([String: Playlist].self, forKey: .playlist) {
            self.playlist = []
        } else {
            self.playlist = []
        }
    }
}

// MARK: - Playlist
struct Playlist: Codable, Equatable {
    let id, userID: StringOrInt
    let name, created: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case name, created
    }
}

struct DeliveryAddress: Codable, Equatable {
    let id: Int?
    var label: String?
    let userID: Int?
    let lat, long, city, state: String?
    let countryID: Int?
    let zip, street, apartment, entryCode: String?
    let buildingName: String?
    let dropoffOption: Int?
    let locationString, instructions: String?
    let deliveryAddressDefault: Int?
    let created, streetNum: String?

    enum CodingKeys: String, CodingKey {
        case id, label
        case userID = "user_id"
        case lat, long, city, state
        case countryID = "country_id"
        case zip, street, apartment
        case entryCode = "entry_code"
        case buildingName = "building_name"
        case dropoffOption = "dropoff_option"
        case locationString = "location_string"
        case instructions
        case deliveryAddressDefault = "default"
        case created
        case streetNum = "street_num"
    }
    
    init(id: Int? = nil, label: String? = nil, userID: Int? = nil, lat: String? = nil, long: String? = nil, city: String? = nil, state: String? = nil, countryID: Int? = nil, zip: String? = nil, street: String? = nil, apartment: String? = nil, entryCode: String? = nil, buildingName: String? = nil, dropoffOption: Int? = nil, locationString: String? = nil, instructions: String? = nil, deliveryAddressDefault: Int? = nil, created: String? = nil, streetNum: String? = nil) {
        self.id = id
        self.label = label
        self.userID = userID
        self.lat = lat
        self.long = long
        self.city = city
        self.state = state
        self.countryID = countryID
        self.zip = zip
        self.street = street
        self.apartment = apartment
        self.entryCode = entryCode
        self.buildingName = buildingName
        self.dropoffOption = dropoffOption
        self.locationString = locationString
        self.instructions = instructions
        self.deliveryAddressDefault = deliveryAddressDefault
        self.created = created
        self.streetNum = streetNum
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        label = try container.decodeIfPresent(String.self, forKey: .label)
        userID = try container.decodeIfPresent(Int.self, forKey: .userID)
        lat = try container.decodeIfPresent(String.self, forKey: .lat)
        long = try container.decodeIfPresent(String.self, forKey: .long)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        countryID = try container.decodeIfPresent(Int.self, forKey: .countryID)
        zip = try container.decodeIfPresent(String.self, forKey: .zip)
        street = try container.decodeIfPresent(String.self, forKey: .street)
        apartment = try container.decodeIfPresent(String.self, forKey: .apartment)
        entryCode = try container.decodeIfPresent(String.self, forKey: .entryCode)
        buildingName = try container.decodeIfPresent(String.self, forKey: .buildingName)
        dropoffOption = try container.decodeIfPresent(Int.self, forKey: .dropoffOption)
        locationString = try container.decodeIfPresent(String.self, forKey: .locationString)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        deliveryAddressDefault = try container.decodeIfPresent(Int.self, forKey: .deliveryAddressDefault)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        streetNum = try container.decodeIfPresent(String.self, forKey: .streetNum)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(label, forKey: .label)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(long, forKey: .long)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(countryID, forKey: .countryID)
        try container.encodeIfPresent(zip, forKey: .zip)
        try container.encodeIfPresent(street, forKey: .street)
        try container.encodeIfPresent(apartment, forKey: .apartment)
        try container.encodeIfPresent(entryCode, forKey: .entryCode)
        try container.encodeIfPresent(buildingName, forKey: .buildingName)
        try container.encodeIfPresent(dropoffOption, forKey: .dropoffOption)
        try container.encodeIfPresent(locationString, forKey: .locationString)
        try container.encodeIfPresent(instructions, forKey: .instructions)
        try container.encodeIfPresent(deliveryAddressDefault, forKey: .deliveryAddressDefault)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(streetNum, forKey: .streetNum)
    }
}
