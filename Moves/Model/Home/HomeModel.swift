//
//  HomeModel.swift
// //
//
//  Created by Wasiq Tayyab on 30/05/2024.
//

import Foundation

// MARK: - HomeResponse
struct HomeResponse: Codable {
    let code: Int
    var msg: [HomeResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([HomeResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
 
}

// MARK: - Msg
struct HomeResponseMsg: Codable, Equatable {
    static func == (lhs: HomeResponseMsg, rhs: HomeResponseMsg) -> Bool {
       return lhs.video == rhs.video
    }
    var video: Video?
    var user: HomeUser?
    var sound: Sound?
    let pinComment: PinComment?

    let location: HomeLocation?
    var store: Store?
    
    let hashtagVideo: HashtagVideo?
    let hashtag: VideoHashtag?

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case sound = "Sound"
        case pinComment = "PinComment"
        case location = "Location"
        case store = "Store"
        case hashtagVideo = "HashtagVideo"
        case hashtag = "Hashtag"
    }

    // Custom encoding to handle encoding of optional properties
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(sound, forKey: .sound)
        try container.encodeIfPresent(pinComment, forKey: .pinComment)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(store, forKey: .store)
        try container.encodeIfPresent(hashtagVideo, forKey: .hashtagVideo)
        try container.encodeIfPresent(hashtag, forKey: .hashtag)
    }
}


class HomeUser: Codable, Equatable {
    static func == (lhs: HomeUser, rhs: HomeUser) -> Bool {
        return lhs.id == rhs.id &&
        lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.bio == rhs.bio &&
        lhs.website == rhs.website &&
        lhs.auth_token == rhs.auth_token &&
        lhs.profilePic == rhs.profilePic &&
        lhs.profilePicSmall == rhs.profilePicSmall &&
        lhs.profileGIF == rhs.profileGIF &&
        lhs.deviceToken == rhs.deviceToken &&
        lhs.business == rhs.business &&
        lhs.parent == rhs.parent &&
        lhs.username == rhs.username &&
        lhs.verified == rhs.verified &&
        lhs.pushNotification == rhs.pushNotification &&
        lhs.privacySetting == rhs.privacySetting &&
        lhs.button == rhs.button &&
        lhs.videoCount == rhs.videoCount &&
        lhs.followersCount == rhs.followersCount &&
        lhs.likesCount == rhs.likesCount &&
        lhs.followingCount == rhs.followingCount &&
        lhs.block == rhs.block &&
        lhs.soldItemsCount == rhs.soldItemsCount &&
        lhs.taggedProductsCount == rhs.taggedProductsCount &&
        lhs.store == rhs.store &&
        lhs.social == rhs.social &&
        lhs.notification == rhs.notification &&
        lhs.unreadNotification == rhs.unreadNotification &&
        lhs.email == rhs.email &&
        lhs.wallet == rhs.wallet &&
        lhs.interests == rhs.interests &&
        lhs.phone == rhs.phone
    }
    
    let id: Int?
    var firstName: String?
    var lastName: String?
    var bio: String?
    var website: String?
    var auth_token:String?
    var profilePic: String?
    let profilePicSmall: String?
    let profileGIF: String?
    let deviceToken: String?
    let business: Int?
    let parent: Int?
    var username: String?
    let verified: Int?
    let pushNotification: PushNotification?
    let privacySetting: PrivacySetting?
    var button: String?
    let videoCount: Int?
    var followersCount: Int?
    var likesCount: Int?
    var followingCount: Int?
    var block: Int?
    let soldItemsCount: Int?
    let taggedProductsCount: Int?
    var store: Store?
    let social: String?
    let notification, unreadNotification: Int?
    var email: String?
    let wallet: StringOrInt?
    let interests: [InterestElement]?
    let phone: String?
  
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["id"] = id
        dict["firstName"] = firstName
        dict["auth_token"] = auth_token
        dict["bio"] = bio
        dict["bio"] = bio
        dict["website"] = website
        dict["profilePic"] = profilePic
        dict["profilePicSmall"] = profilePicSmall
        dict["profileGIF"] = profileGIF
        dict["deviceToken"] = deviceToken
        dict["business"] = business
        dict["parent"] = parent
        dict["username"] = username
        dict["verified"] = verified
        dict["button"] = button
        dict["videoCount"] = videoCount
        dict["followersCount"] = followersCount
        dict["likesCount"] = likesCount
        dict["followingCount"] = followingCount
        dict["block"] = block
        dict["soldItemsCount"] = soldItemsCount
        dict["taggedProductsCount"] = taggedProductsCount
        return dict
    }

    enum CodingKeys: String, CodingKey {
        case id, firstName = "first_name", lastName = "last_name", bio, website, profilePic = "profile_pic", profilePicSmall = "profile_pic_small", profileGIF = "profile_gif", deviceToken = "device_token", business, parent, username, verified, pushNotification = "PushNotification", privacySetting = "PrivacySetting", followersCount = "followers_count", followingCount = "following_count", likesCount = "likes_count", videoCount = "video_count", button, block, soldItemsCount = "sold_items_count", taggedProductsCount = "tagged_products_count", social, notification, unreadNotification = "unread_notification", email, wallet, interests = "Interests", phone, store = "Store",auth_token = "auth_token"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        auth_token = try container.decodeIfPresent(String.self, forKey: .auth_token)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        website = try container.decodeIfPresent(String.self, forKey: .website)
        profilePic = try container.decodeIfPresent(String.self, forKey: .profilePic)
        profilePicSmall = try container.decodeIfPresent(String.self, forKey: .profilePicSmall)
        profileGIF = try container.decodeIfPresent(String.self, forKey: .profileGIF)
        deviceToken = try container.decodeIfPresent(String.self, forKey: .deviceToken)
        business = try container.decodeIfPresent(Int.self, forKey: .business)
        parent = try container.decodeIfPresent(Int.self, forKey: .parent)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        verified = try container.decodeIfPresent(Int.self, forKey: .verified)
        pushNotification = try container.decodeIfPresent(PushNotification.self, forKey: .pushNotification)
        privacySetting = try container.decodeIfPresent(PrivacySetting.self, forKey: .privacySetting)
        button = try container.decodeIfPresent(String.self, forKey: .button)
        videoCount = try container.decodeIfPresent(Int.self, forKey: .videoCount)
        followersCount = try container.decodeIfPresent(Int.self, forKey: .followersCount)
        likesCount = try container.decodeIfPresent(Int.self, forKey: .likesCount)
        followingCount = try container.decodeIfPresent(Int.self, forKey: .followingCount)
        block = try container.decodeIfPresent(Int.self, forKey: .block)
        soldItemsCount = try container.decodeIfPresent(Int.self, forKey: .soldItemsCount)
        taggedProductsCount = try container.decodeIfPresent(Int.self, forKey: .taggedProductsCount)
        social = try container.decodeIfPresent(String.self, forKey: .social)
        unreadNotification = try container.decodeIfPresent(Int.self, forKey: .unreadNotification)
        notification = try container.decodeIfPresent(Int.self, forKey: .notification)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        wallet = try container.decodeIfPresent(StringOrInt.self, forKey: .wallet)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        if let interestsArr = try? container.decodeIfPresent([InterestElement].self, forKey: .interests) {
            self.interests = interestsArr
        } else if let _ = try? container.decodeIfPresent([String: InterestElement].self, forKey: .interests) {
            self.interests = []
        } else {
            self.interests = []
        }
        
        if let storeData = try? container.decodeIfPresent(Store.self, forKey: .store) {
            store = storeData
        } else {
            store = nil
        }

    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(firstName, forKey: .firstName)
        try container.encodeIfPresent(lastName, forKey: .lastName)
        try container.encodeIfPresent(auth_token, forKey: .auth_token)
        try container.encodeIfPresent(bio, forKey: .bio)
        try container.encodeIfPresent(website, forKey: .website)
        try container.encodeIfPresent(profilePic, forKey: .profilePic)
        try container.encodeIfPresent(profilePicSmall, forKey: .profilePicSmall)
        try container.encodeIfPresent(profileGIF, forKey: .profileGIF)
        try container.encodeIfPresent(deviceToken, forKey: .deviceToken)
        try container.encodeIfPresent(business, forKey: .business)
        try container.encodeIfPresent(parent, forKey: .parent)
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(verified, forKey: .verified)
        try container.encodeIfPresent(pushNotification, forKey: .pushNotification)
        try container.encodeIfPresent(privacySetting, forKey: .privacySetting)
        try container.encodeIfPresent(button, forKey: .button)
        try container.encodeIfPresent(videoCount, forKey: .videoCount)
        try container.encodeIfPresent(followersCount, forKey: .followersCount)
        try container.encodeIfPresent(likesCount, forKey: .likesCount)
        try container.encodeIfPresent(followingCount, forKey: .followingCount)
        try container.encodeIfPresent(block, forKey: .block)
        try container.encodeIfPresent(soldItemsCount, forKey: .soldItemsCount)
        try container.encodeIfPresent(taggedProductsCount, forKey: .taggedProductsCount)
        try container.encodeIfPresent(social, forKey: .social)
        try container.encodeIfPresent(unreadNotification, forKey: .unreadNotification)
        try container.encodeIfPresent(notification, forKey: .notification)
        try container.encodeIfPresent(email, forKey: .email)
        try container.encodeIfPresent(wallet, forKey: .wallet)
        try container.encodeIfPresent(interests, forKey: .interests)
        try container.encodeIfPresent(phone, forKey: .phone)
        if let store = store {
            try container.encode(store, forKey: .store)
        } else {
            try container.encode([String: String](), forKey: .store) // Empty dictionary if store is nil
        }
    }
}



// MARK: - Location
struct HomeLocation: Codable {
    let id: Int?
    let name, string, lat, long: String?
    let googlePlaceID: String?
    let image: String?
    let created: String?

    enum CodingKeys: String, CodingKey {
        case id, name, string, lat, long
        case googlePlaceID = "google_place_id"
        case image, created
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        string = try container.decodeIfPresent(String.self, forKey: .string)
        lat = try container.decodeIfPresent(String.self, forKey: .lat)
        long = try container.decodeIfPresent(String.self, forKey: .long)
        googlePlaceID = try container.decodeIfPresent(String.self, forKey: .googlePlaceID)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        created = try container.decodeIfPresent(String.self, forKey: .created)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(string, forKey: .string)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(long, forKey: .long)
        try container.encodeIfPresent(googlePlaceID, forKey: .googlePlaceID)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(created, forKey: .created)
    }
}



// MARK: - PinComment
struct PinComment: Codable {
    let id, userID, videoID, comment: Int?
    let created: String?

    enum CodingKeys: String, CodingKey {
        case id      = "id"
        case userID = "user_id"
        case videoID = "video_id"
        case comment, created
    }
  
}

struct VideoProduct: Codable {
    let id: Int?
    let type: String?
    let videoID, storeID,dish_id: Int?
    let productID, updatedAt: String?
    let productMealmeJson: String?
    let store: Store?
 
    enum CodingKeys: String, CodingKey {
        case id, type
        case videoID = "video_id"
        case storeID = "store_id"
        case dish_id = "dish_id"
        case productID = "product_id"
        case updatedAt = "updated_at"
        case store = "Store"
        case dish = "Dish"
        case productMealmeJson = "product_mealme_json"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.dish_id = try container.decodeIfPresent(Int.self, forKey: .dish_id)

        self.type = try container.decodeIfPresent(String.self, forKey: .type)
        self.videoID = try container.decodeIfPresent(Int.self, forKey: .videoID)
        self.storeID = try container.decodeIfPresent(Int.self, forKey: .storeID)
        self.productID = try container.decodeIfPresent(String.self, forKey: .productID)
        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        self.store = try container.decodeIfPresent(Store.self, forKey: .store)
        self.productMealmeJson = try container.decodeIfPresent(String.self, forKey: .productMealmeJson)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(dish_id, forKey: .dish_id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(videoID, forKey: .videoID)
        try container.encodeIfPresent(storeID, forKey: .storeID)
        try container.encodeIfPresent(productID, forKey: .productID)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(store, forKey: .store)
        try container.encodeIfPresent(productMealmeJson, forKey: .productMealmeJson)
    }
}

struct Store: Codable, Equatable {
    let id, userID: Int?
    let mealmeStoreID, name, description, phoneNumber: String?
    let foodPhotos, logoPhotos: String?
    let logo, cover, latitude, longitude: String?
    let type, pickupEnabled, deliveryEnabled, created: String?
    var user: HomeUser?
    var storeAddress: StoreAddress?
    let storeLocalHours: [StoreLocalHour]?
    var local_store: Int?
    let weightedRatingValue: Double?
    let aggregatedRatingCount, status: Int?
    let inactiveReason, cuisine: String?
    let store_type: String?
    
    func toDictionary() -> [String: Any] {
        var dict = [String: Any]()
        dict["id"] = id
        dict["user_id"] = userID
        dict["mealme_store_id"] = mealmeStoreID
        dict["name"] = name
        dict["description"] = description
        dict["phone_number"] = phoneNumber
        dict["food_photos"] = foodPhotos
        dict["logo_photos"] = logoPhotos
        dict["logo"] = logo
        dict["cover"] = cover
        dict["latitude"] = latitude
        dict["longitude"] = longitude
        dict["type"] = type
        dict["pickup_enabled"] = pickupEnabled
        dict["delivery_enabled"] = deliveryEnabled
        dict["created"] = created
        dict["user"] = user?.toDictionary()
        dict["storeAddress"] = storeAddress?.toDictionary()
        dict["storeLocalHours"] = storeLocalHours?.map { $0.toDictionary() }
        dict["weighted_rating_value"] = weightedRatingValue
        dict["aggregated_rating_count"] = aggregatedRatingCount
        dict["cuisine"] = cuisine
        dict["store_type"] = store_type
        return dict
    }
    
    // Define two sets of CodingKeys
    enum CodingKeys1: String, CodingKey {
        case id
        case userID = "user_id"
        case mealmeStoreID = "mealme_store_id"
        case name, description
        case phoneNumber = "phone_number"
        case foodPhotos = "food_photos"
        case logoPhotos = "logo_photos"
        case logo, cover, latitude, longitude, type
        case pickupEnabled = "pickup_enabled"
        case deliveryEnabled = "delivery_enabled"
        case local_store = "local_store"
        case created
        case user = "User"
        case storeAddress = "StoreAddress"
        case storeLocalHours = "StoreLocalHours"
        case weightedRatingValue = "weighted_rating_value"
        case aggregatedRatingCount = "aggregated_rating_count"
        case status
        case inactiveReason = "inactive_reason"
        case cuisine
        case store_type = "store_type"
    }
    
    enum CodingKeys2: String, CodingKey {
        case id
        case userID = "user_id"
        case mealmeStoreID = "mealme_store_id"
        case name, description
        case phoneNumber = "phone_number"
        case foodPhotos = "food_photos"
        case logoPhotos = "logo_photos"
        case logo, cover, latitude, longitude, type
        case pickupEnabled = "pickup_enabled"
        case deliveryEnabled = "delivery_enabled"
        case local_store = "local_store"
        case created
        case user
        case storeAddress
        case storeLocalHours
        case weightedRatingValue = "weighted_rating_value"
        case aggregatedRatingCount = "aggregated_rating_count"
        case status
        case inactiveReason = "inactive_reason"
        case cuisine
        case store_type = "store_type"
    }
    
    init(from decoder: Decoder) throws {
        if ConstantManager.isFetchProduct {
            let container = try decoder.container(keyedBy: CodingKeys2.self)
            self.id = try container.decodeIfPresent(Int.self, forKey: .id)
            self.userID = try container.decodeIfPresent(Int.self, forKey: .userID)
            self.local_store = try container.decodeIfPresent(Int.self, forKey: .local_store)
            self.mealmeStoreID = try container.decodeIfPresent(String.self, forKey: .mealmeStoreID)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
            self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
            self.foodPhotos = try container.decodeIfPresent(String.self, forKey: .foodPhotos)
            self.logoPhotos = try container.decodeIfPresent(String.self, forKey: .logoPhotos)
            self.logo = try container.decodeIfPresent(String.self, forKey: .logo)
            self.cover = try container.decodeIfPresent(String.self, forKey: .cover)
            self.latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
            self.longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
            self.type = try container.decodeIfPresent(String.self, forKey: .type)
            self.pickupEnabled = try container.decodeIfPresent(String.self, forKey: .pickupEnabled)
            self.deliveryEnabled = try container.decodeIfPresent(String.self, forKey: .deliveryEnabled)
            self.created = try container.decodeIfPresent(String.self, forKey: .created)
            self.user = try container.decodeIfPresent(HomeUser.self, forKey: .user)
            self.storeAddress = try container.decodeIfPresent(StoreAddress.self, forKey: .storeAddress)
            self.storeLocalHours = try container.decodeIfPresent([StoreLocalHour].self, forKey: .storeLocalHours)
            self.weightedRatingValue = try container.decodeIfPresent(Double.self, forKey: .weightedRatingValue)
            self.aggregatedRatingCount = try container.decodeIfPresent(Int.self, forKey: .aggregatedRatingCount)
            self.status = try container.decodeIfPresent(Int.self, forKey: .status)
            self.inactiveReason = try container.decodeIfPresent(String.self, forKey: .inactiveReason)
            self.cuisine = try container.decodeIfPresent(String.self, forKey: .cuisine)
            self.store_type = try container.decodeIfPresent(String.self, forKey: .store_type)
        } else {
            let container = try decoder.container(keyedBy: CodingKeys1.self)
            self.id = try container.decodeIfPresent(Int.self, forKey: .id)
            self.userID = try container.decodeIfPresent(Int.self, forKey: .userID)
            self.local_store = try container.decodeIfPresent(Int.self, forKey: .local_store)
            self.mealmeStoreID = try container.decodeIfPresent(String.self, forKey: .mealmeStoreID)
            self.name = try container.decodeIfPresent(String.self, forKey: .name)
            self.description = try container.decodeIfPresent(String.self, forKey: .description)
            self.phoneNumber = try container.decodeIfPresent(String.self, forKey: .phoneNumber)
            self.foodPhotos = try container.decodeIfPresent(String.self, forKey: .foodPhotos)
            self.logoPhotos = try container.decodeIfPresent(String.self, forKey: .logoPhotos)
            self.logo = try container.decodeIfPresent(String.self, forKey: .logo)
            self.cover = try container.decodeIfPresent(String.self, forKey: .cover)
            self.latitude = try container.decodeIfPresent(String.self, forKey: .latitude)
            self.longitude = try container.decodeIfPresent(String.self, forKey: .longitude)
            self.type = try container.decodeIfPresent(String.self, forKey: .type)
            self.pickupEnabled = try container.decodeIfPresent(String.self, forKey: .pickupEnabled)
            self.deliveryEnabled = try container.decodeIfPresent(String.self, forKey: .deliveryEnabled)
            self.created = try container.decodeIfPresent(String.self, forKey: .created)
            self.user = try container.decodeIfPresent(HomeUser.self, forKey: .user)
            self.storeAddress = try container.decodeIfPresent(StoreAddress.self, forKey: .storeAddress)
            self.storeLocalHours = try container.decodeIfPresent([StoreLocalHour].self, forKey: .storeLocalHours)
            self.weightedRatingValue = try container.decodeIfPresent(Double.self, forKey: .weightedRatingValue)
            self.aggregatedRatingCount = try container.decodeIfPresent(Int.self, forKey: .aggregatedRatingCount)
            self.status = try container.decodeIfPresent(Int.self, forKey: .status)
            self.inactiveReason = try container.decodeIfPresent(String.self, forKey: .inactiveReason)
            self.cuisine = try container.decodeIfPresent(String.self, forKey: .cuisine)
            self.store_type = try container.decodeIfPresent(String.self, forKey: .store_type)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        if ConstantManager.isFetchProduct {
            var container = encoder.container(keyedBy: CodingKeys2.self)
            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(userID, forKey: .userID)
            try container.encodeIfPresent(mealmeStoreID, forKey: .mealmeStoreID)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encodeIfPresent(description, forKey: .description)
            try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
            try container.encodeIfPresent(foodPhotos, forKey: .foodPhotos)
            try container.encodeIfPresent(logoPhotos, forKey: .logoPhotos)
            try container.encodeIfPresent(logo, forKey: .logo)
            try container.encodeIfPresent(cover, forKey: .cover)
            try container.encodeIfPresent(latitude, forKey: .latitude)
            try container.encodeIfPresent(longitude, forKey: .longitude)
            try container.encodeIfPresent(type, forKey: .type)
            try container.encodeIfPresent(pickupEnabled, forKey: .pickupEnabled)
            try container.encodeIfPresent(deliveryEnabled, forKey: .deliveryEnabled)
            try container.encodeIfPresent(created, forKey: .created)
            try container.encodeIfPresent(user, forKey: .user)
            try container.encodeIfPresent(storeAddress, forKey: .storeAddress)
            try container.encodeIfPresent(storeLocalHours, forKey: .storeLocalHours)
            try container.encodeIfPresent(weightedRatingValue, forKey: .weightedRatingValue)
            try container.encodeIfPresent(aggregatedRatingCount, forKey: .aggregatedRatingCount)
            try container.encodeIfPresent(status, forKey: .status)
            try container.encodeIfPresent(inactiveReason, forKey: .inactiveReason)
            try container.encodeIfPresent(cuisine, forKey: .cuisine)
            try container.encodeIfPresent(store_type, forKey: .store_type)
        } else {
            var container = encoder.container(keyedBy: CodingKeys1.self)
            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(userID, forKey: .userID)
            try container.encodeIfPresent(mealmeStoreID, forKey: .mealmeStoreID)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encodeIfPresent(description, forKey: .description)
            try container.encodeIfPresent(phoneNumber, forKey: .phoneNumber)
            try container.encodeIfPresent(foodPhotos, forKey: .foodPhotos)
            try container.encodeIfPresent(logoPhotos, forKey: .logoPhotos)
            try container.encodeIfPresent(logo, forKey: .logo)
            try container.encodeIfPresent(cover, forKey: .cover)
            try container.encodeIfPresent(latitude, forKey: .latitude)
            try container.encodeIfPresent(longitude, forKey: .longitude)
            try container.encodeIfPresent(type, forKey: .type)
            try container.encodeIfPresent(pickupEnabled, forKey: .pickupEnabled)
            try container.encodeIfPresent(deliveryEnabled, forKey: .deliveryEnabled)
            try container.encodeIfPresent(created, forKey: .created)
            try container.encodeIfPresent(user, forKey: .user)
            try container.encodeIfPresent(storeAddress, forKey: .storeAddress)
            try container.encodeIfPresent(storeLocalHours, forKey: .storeLocalHours)
            try container.encodeIfPresent(weightedRatingValue, forKey: .weightedRatingValue)
            try container.encodeIfPresent(aggregatedRatingCount, forKey: .aggregatedRatingCount)
            try container.encodeIfPresent(status, forKey: .status)
            try container.encodeIfPresent(inactiveReason, forKey: .inactiveReason)
            try container.encodeIfPresent(cuisine, forKey: .cuisine)
            try container.encodeIfPresent(store_type, forKey: .store_type)
        }
    }
}



struct StoreAddress: Codable, Equatable {
    let id, storeID: Int
    let city: String
    let state: String
    let countryID: Int
    let latitude, longitude, zipcode: String
    let country: String
    let streetAddr: String
    let apt_suite: String

    enum CodingKeys: String, CodingKey {
        case id
        case storeID = "store_id"
        case city, state
        case countryID = "country_id"
        case latitude, longitude, zipcode, country
        case streetAddr = "street_addr"
        case apt_suite = "apt_suite"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        storeID = try container.decodeIfPresent(Int.self, forKey: .storeID) ?? 0
        city = try container.decodeIfPresent(String.self, forKey: .city) ?? ""
        state = try container.decodeIfPresent(String.self, forKey: .state) ?? ""
        countryID = try container.decodeIfPresent(Int.self, forKey: .countryID) ?? 0
        latitude = try container.decodeIfPresent(String.self, forKey: .latitude) ?? ""
        longitude = try container.decodeIfPresent(String.self, forKey: .longitude) ?? ""
        zipcode = try container.decodeIfPresent(String.self, forKey: .zipcode) ?? ""
        country = try container.decodeIfPresent(String.self, forKey: .country) ?? ""
        streetAddr = try container.decodeIfPresent(String.self, forKey: .streetAddr) ?? ""
        apt_suite = try container.decodeIfPresent(String.self, forKey: .apt_suite) ?? ""
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(storeID, forKey: .storeID)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(countryID, forKey: .countryID)
        try container.encodeIfPresent(latitude, forKey: .latitude)
        try container.encodeIfPresent(longitude, forKey: .longitude)
        try container.encodeIfPresent(zipcode, forKey: .zipcode)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(streetAddr, forKey: .streetAddr)
        try container.encodeIfPresent(apt_suite, forKey: .apt_suite)
    }
    
    func toDictionary() -> [String: Any] {
            var dict: [String: Any] = [:]
            dict["id"] = id
            dict["store_id"] = storeID
            dict["city"] = city
            dict["state"] = state
            dict["apt_suite"] = apt_suite
            dict["latitude"] = latitude
            dict["longitude"] = longitude
            dict["zipcode"] = zipcode
            dict["country"] = country
            dict["street_addr"] = streetAddr
            return dict
        }
}

enum StringOrInt: Codable, Equatable {
    case string(String)
    case int(Int)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else {
            throw DecodingError.typeMismatch(StringOrInt.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected either Int or String"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        }
    }
    
    var stringValue: String? {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return String(value)
        }
    }
    
    var intValue: Int? {
        switch self {
        case .string(let value):
            return Int(value)
        case .int(let value):
            return value
        }
    }
}
