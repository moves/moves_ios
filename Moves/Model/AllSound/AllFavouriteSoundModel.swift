//
//  AllFavouriteSoundModel.swift
// //
//
//  Created by Macbook Pro on 18/09/2024.
//

import Foundation
struct AllFavouriteSoundResponse : Codable {
    let code : Int?
    var msg : [FavouriteSoundMSG]?

    enum CodingKeys: String, CodingKey {

        case code = "code"
        case msg = "msg"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        code = try values.decodeIfPresent(Int.self, forKey: .code)
        if let array = try? values.decodeIfPresent([FavouriteSoundMSG].self, forKey: .msg) {
            msg = array
        } else if let singleValue = try? values.decodeIfPresent(String.self, forKey: .msg) {
            print("Received msg as a string: \(singleValue)")
            msg = nil
        }
    }

}
struct FavouriteSoundMSG : Codable {
    let soundFavourite : SoundFavourite?
    let sound : Sound?
    let user : User?

    enum CodingKeys: String, CodingKey {

        case soundFavourite = "SoundFavourite"
        case sound = "Sound"
        case user = "User"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        soundFavourite = try values.decodeIfPresent(SoundFavourite.self, forKey: .soundFavourite)
        sound = try values.decodeIfPresent(Sound.self, forKey: .sound)
        user = try values.decodeIfPresent(User.self, forKey: .user)
    }

}
struct SoundFavourite : Codable {
    let id : Int?
    let user_id : Int?
    let sound_id : Int?
    let created : String?

    enum CodingKeys: String, CodingKey {

        case id = "id"
        case user_id = "user_id"
        case sound_id = "sound_id"
        case created = "created"
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        user_id = try values.decodeIfPresent(Int.self, forKey: .user_id)
        sound_id = try values.decodeIfPresent(Int.self, forKey: .sound_id)
        created = try values.decodeIfPresent(String.self, forKey: .created)
    }

}

