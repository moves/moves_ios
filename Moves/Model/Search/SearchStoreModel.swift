//
//  SearchStoreModel.swift
// //
//
//  Created by Wasiq Tayyab on 14/07/2024.
//

import Foundation
// MARK: - SearchStoreResponse
struct SearchStoreResponse: Codable {
    let code: Int
    var msg: [SearchStoreResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([SearchStoreResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct SearchStoreResponseMsg: Codable {
    var store: Store?
    var user: HomeUser?
    
    enum CodingKeys: String, CodingKey {
        case store = "Store"
        case user = "User"
    }
    
    init(store: Store?, user: HomeUser?) {
        self.store = store
        self.user = user
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        store = try container.decodeIfPresent(Store.self, forKey: .store)
        user = try container.decodeIfPresent(HomeUser.self, forKey: .user)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(store, forKey: .store)
        try container.encodeIfPresent(user, forKey: .user)
    }
}


struct StoreLocalHour: Codable, Equatable {
    let id: Int
    let storeID: Int
    let day: String
    let operational: String?
    let delivery: String?
    let pickup: String?
    let dineIn: String?
    let created: String
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["store_id"] = storeID
        dict["day"] = day
        dict["operational"] = operational
        dict["delivery"] = delivery
        dict["pickup"] = pickup
        dict["dine_in"] = dineIn
        dict["created"] = created
        return dict
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case storeID = "store_id"
        case day, operational, delivery, pickup
        case dineIn = "dine_in"
        case created
    }
    
    init(id: Int, storeID: Int, day: String, operational: String?, delivery: String?, pickup: String?, dineIn: String?, created: String) {
        self.id = id
        self.storeID = storeID
        self.day = day
        self.operational = operational
        self.delivery = delivery
        self.pickup = pickup
        self.dineIn = dineIn
        self.created = created
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        storeID = try container.decode(Int.self, forKey: .storeID)
        day = try container.decode(String.self, forKey: .day)
        operational = try container.decodeIfPresent(String.self, forKey: .operational)
        delivery = try container.decodeIfPresent(String.self, forKey: .delivery)
        pickup = try container.decodeIfPresent(String.self, forKey: .pickup)
        dineIn = try container.decodeIfPresent(String.self, forKey: .dineIn)
        created = try container.decode(String.self, forKey: .created)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(storeID, forKey: .storeID)
        try container.encode(day, forKey: .day)
        try container.encodeIfPresent(operational, forKey: .operational)
        try container.encodeIfPresent(delivery, forKey: .delivery)
        try container.encodeIfPresent(pickup, forKey: .pickup)
        try container.encodeIfPresent(dineIn, forKey: .dineIn)
        try container.encode(created, forKey: .created)
    }
}

