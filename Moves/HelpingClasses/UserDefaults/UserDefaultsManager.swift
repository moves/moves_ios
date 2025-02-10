//
//  UserDefaultsManager.swift
//  ParkSpace
//
//  Created by Zubair Ahmed on 02/03/2022.
//

import Foundation
import UIKit
fileprivate enum UserDefaultsKey : String {
    case user_id            = "user_id"
    case otherUserID            = "otherUserID"
    case ip                 = "ip"
    case auth_token         = "auth_token"
    case device_token       = "device_token"
    case deviceID       = "deviceID"
    case country_id       = "country_id"
    case saveAudioFilePath       = "saveAudioFilePath"
    case wallet =            "wallet"
    case sound_id = "sound_id"
    case spaceRoomId = "spaceRoomId"
    case LiveStreamingId = "LiveStreamingId"
    case verificationID = "verificationID"
    case authToken = "authToken"
    case latitude = "latitude"
    case longitude = "longitude"
    case username = "username"
    case profileUser = "profileUser"
    case soundName = "soundName"
    case sound_url = "sound_url"
    case sound_second = "sound_second"
    case paypal_email = "paypal_email"
    case location_name = "location_name"
    case location_address = "location_address"
    case payment_method_id = "payment_method_id"
    case payment_id = "payment_id"
    case location_id = "location_id"
    case cardLastNumber = "cardLastNumber"
    case cardExpiry = "cardExpiry"
    case phone = "phone"
    case business = "business"
    case businessProfile = "businessProfile"
    case store_id = "store_id"
    case idAuthToken = "idAuthToken"
}

fileprivate class UserDefault {
    static func _set(value : Any?, key : UserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    static func _get(valueForKey  Key: UserDefaultsKey) -> Any? {
        return UserDefaults.standard.value(forKey: Key.rawValue)
    }
}
class UserDefaultsManager
{
    class var shared: UserDefaultsManager {
        struct Static {
            static let instance = UserDefaultsManager()
        }
        return Static.instance
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    
    var store_id : Int {
        set{
            UserDefault._set(value: newValue, key: .store_id)
        } get {
            return UserDefault._get(valueForKey: .store_id) as? Int ?? 0
        }
    }
    
    var location_id : Int {
        set{
            UserDefault._set(value: newValue, key: .location_id)
        } get {
            return UserDefault._get(valueForKey: .location_id) as? Int ?? 0
        }
    }
    
    var business : String {
        set{
            UserDefault._set(value: newValue, key: .business)
        } get {
            return UserDefault._get(valueForKey: .business) as? String ?? ""
        }
    }
    var user_email : String {
        set{
            UserDefault._set(value: newValue, key: .business)
        } get {
            return UserDefault._get(valueForKey: .business) as? String ?? ""
        }
    }
    
//    var businessProfile : Int {
//        set{
//            UserDefault._set(value: newValue, key: .businessProfile)
//        } get {
//            return UserDefault._get(valueForKey: .businessProfile) as? Int ?? 0
//        }
//    }
//    
    var phone : String {
        set{
            UserDefault._set(value: newValue, key: .phone)
        } get {
            return UserDefault._get(valueForKey: .phone) as? String ?? ""
        }
    }
    
    var cardLastNumber : String {
        set{
            UserDefault._set(value: newValue, key: .cardLastNumber)
        } get {
            return UserDefault._get(valueForKey: .cardLastNumber) as? String ?? ""
        }
    }
    
    var cardExpiry : String {
        set{
            UserDefault._set(value: newValue, key: .cardExpiry)
        } get {
            return UserDefault._get(valueForKey: .cardExpiry) as? String ?? ""
        }
    }
    
    var payment_method_id : String {
        set{
            UserDefault._set(value: newValue, key: .payment_method_id)
        } get {
            return UserDefault._get(valueForKey: .payment_method_id) as? String ?? ""
        }
    }
    var payment_id : String {
        set{
            UserDefault._set(value: newValue, key: .payment_id)
        } get {
            return UserDefault._get(valueForKey: .payment_id) as? String ?? ""
        }
    }
    
    var authToken : String {
        set{
            UserDefault._set(value: newValue, key: .authToken)
        } get {
            return UserDefault._get(valueForKey: .authToken) as? String ?? "0"
        }
    }
    
    // new API
    var idAuthToken : String {
        set{
            UserDefault._set(value: newValue, key: .idAuthToken)
        } get {
            return UserDefault._get(valueForKey: .idAuthToken) as? String ?? ""
        }
    }
    
    var location_name : String {
        set{
            UserDefault._set(value: newValue, key: .location_name)
        } get {
            return UserDefault._get(valueForKey: .location_name) as? String ?? ""
        }
    }
    
    var location_address : String {
        set{
            UserDefault._set(value: newValue, key: .location_address)
        } get {
            return UserDefault._get(valueForKey: .location_address) as? String ?? ""
        }
    }
    
    var sound_url : String {
        set{
            UserDefault._set(value: newValue, key: .sound_url)
        } get {
            return UserDefault._get(valueForKey: .sound_url) as? String ?? ""
        }
    }
    
    var paypal_email : String {
        set{
            UserDefault._set(value: newValue, key: .paypal_email)
        } get {
            return UserDefault._get(valueForKey: .paypal_email) as? String ?? ""
        }
    }
    
    var sound_second : String {
        set{
            UserDefault._set(value: newValue, key: .sound_second)
        } get {
            return UserDefault._get(valueForKey: .sound_second) as? String ?? ""
        }
    }
    
    var username : String {
        set{
            UserDefault._set(value: newValue, key: .username)
        } get {
            return UserDefault._get(valueForKey: .username) as? String ?? ""
        }
    }
    
    var profileUser : String {
        set{
            UserDefault._set(value: newValue, key: .profileUser)
        } get {
            return UserDefault._get(valueForKey: .profileUser) as? String ??  "https://app.movesapp.io/mobileapp_api/"
        }
    }
    
    var latitude : Double {
        set{
            UserDefault._set(value: newValue, key: .latitude)
        } get {
            return UserDefault._get(valueForKey: .latitude) as? Double ?? 0.0
        }
    }
    
    var longitude : Double {
        set{
            UserDefault._set(value: newValue, key: .longitude)
        } get {
            return UserDefault._get(valueForKey: .longitude) as? Double ?? 0.0
        }
    }
    
    var user_id : String {
        set{
            UserDefault._set(value: newValue, key: .user_id)
        } get {
            return UserDefault._get(valueForKey: .user_id) as? String ?? "0"
        }
    }
    
    var verificationID : String {
        set{
            UserDefault._set(value: newValue, key: .verificationID)
        } get {
            return UserDefault._get(valueForKey: .verificationID) as? String ?? "0"
        }
    }
    
    var sound_id : String {
        set{
            UserDefault._set(value: newValue, key: .sound_id)
        } get {
            return UserDefault._get(valueForKey: .sound_id) as? String ?? "0"
        }
    }
    
    var sound_name : String {
        set{
            UserDefault._set(value: newValue, key: .soundName)
        } get {
            return UserDefault._get(valueForKey: .soundName) as? String ?? ""
        }
    }
    
    var wallet : String {
        set{
            UserDefault._set(value: newValue, key: .wallet)
        } get {
            return UserDefault._get(valueForKey: .wallet) as? String ?? "0"
        }
    }
    
    var ip : String {
        set{
            UserDefault._set(value: newValue, key: .ip)
        } get {
            return UserDefault._get(valueForKey: .ip) as? String ?? ""
        }
    }
    
    
    var otherUserID : String {
        set{
            UserDefault._set(value: newValue, key: .otherUserID)
        } get {
            return UserDefault._get(valueForKey: .otherUserID) as? String ?? ""
        }
    }
    
//    var auth_token : String {
//        set{
//            UserDefault._set(value: newValue, key: .auth_token)
//        } get {
//            return UserDefault._get(valueForKey: .auth_token) as? String ?? ""
//        }
//    }
//    
    var device_token : String {
        set{
            UserDefault._set(value: newValue, key: .device_token)
        } get {
            return UserDefault._get(valueForKey: .device_token) as? String ?? ""
        }
    }
    
    var LiveStreamingId : String {
        set{
            UserDefault._set(value: newValue, key: .LiveStreamingId)
        } get {
            return UserDefault._get(valueForKey: .LiveStreamingId) as? String ?? ""
        }
    }
    
    
    var deviceID : String {
        set{
            UserDefault._set(value: newValue, key: .deviceID)
        } get {
            return UserDefault._get(valueForKey: .deviceID) as? String ?? ""
        }
    }
    var country_id : String {
        set{
            UserDefault._set(value: newValue, key: .country_id)
        } get {
            return UserDefault._get(valueForKey: .country_id) as? String ?? ""
        }
    }
    var saveAudioFilePath : String {
        set{
            UserDefault._set(value: newValue, key: .saveAudioFilePath)
        } get {
            return UserDefault._get(valueForKey: .saveAudioFilePath) as? String ?? ""
        }
    }
    var spaceRoomId : String {
        set{
            UserDefault._set(value: newValue, key: .spaceRoomId)
        } get {
            return UserDefault._get(valueForKey: .spaceRoomId) as? String ?? ""
        }
    }
}
