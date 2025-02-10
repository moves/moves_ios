//
//  ShowVideoAgainstHashtagModel.swift
// //
//
//  Created by Wasiq Tayyab on 19/06/2024.
//

import Foundation

struct ShowVideosAgainstHashtagResponse: Codable {
    let code: Int
    var msg: ShowVideosAgainstHashtagResponseMsg?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(ShowVideosAgainstHashtagResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
//   
////    let views: String?  // Make this property optional
////    let videosCount: Int?  // Initialize this property
//    var message: String?
//
//    enum CodingKeys: String, CodingKey {
//        case code, msg
//    }
//  
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        code = try container.decode(Int.self, forKey: .code)
//        
//        if code == 200 {
//            msg = try container.decode(ShowVideosAgainstHashtagResponseMsg.self, forKey: .msg)
//            message = nil
//        } else if code == 201 {
//            // When code is 201, msg is expected to be a string
//            let msgString = try container.decode(String.self, forKey: .msg)
//            msg = nil
//            message = msgString
//        } else {
//            msg = nil
//            message = try? container.decode(String.self, forKey: .msg)
//        }
//        
//        views = try? container.decode(String.self, forKey: .views)  // Make views optional
//        videosCount = try? container.decode(Int.self, forKey: .videosCount)
//    }
}

// MARK: - Msg
struct ShowVideosAgainstHashtagResponseMsg: Codable {
    var hashtag: HashtagResponse

    enum CodingKeys: String, CodingKey {
        case hashtag = "Hashtag"
    }
}

// MARK: - Hashtag
struct HashtagResponse: Codable {
    let id: Int
    let name: String
    let favourite: Int
    let views: String
    let videosCount: Int
    var videos: [HomeResponseMsg]

    enum CodingKeys: String, CodingKey {
        case id, name, favourite, views
        case videosCount = "videos_count"
        case videos
    }
}



//// MARK: - Msg
//struct ShowVideosAgainstHashtagResponseMsg: Codable {
//    let hashtagVideo: ShowVideoHashtagVideo
//    let hashtag: ShowVideoHashtag
//    let video: Video
//
//    enum CodingKeys: String, CodingKey {
//        case hashtagVideo = "HashtagVideo"
//        case hashtag = "Hashtag"
//        case video = "Video"
//    }
//}

// MARK: - Hashtag
struct ShowVideoHashtag: Codable {
    let id: Int
    let name: String
    let favourite: Int
}

// MARK: - HashtagVideo
struct ShowVideoHashtagVideo: Codable {
    let id, hashtagID, videoID: Int

    enum CodingKeys: String, CodingKey {
        case id
        case hashtagID = "hashtag_id"
        case videoID = "video_id"
    }
}


// MARK: - AddHashtagFavouriteResponse
struct AddHashtagFavouriteResponse: Codable {
    let code: Int
    var msg: AddHashtagFavouriteResponseMsg?
    let message: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode(AddHashtagFavouriteResponseMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct AddHashtagFavouriteResponseMsg: Codable {
    let hashtagFavourite: HashtagFavourite
    let hashtag: HashtagFav
    let user: UserFav?

    enum CodingKeys: String, CodingKey {
        case hashtagFavourite = "HashtagFavourite"
        case hashtag = "Hashtag"
        case user = "User"
    }
}

// MARK: - Hashtag
struct HashtagFav: Codable {
    let id: Int
    let name: String
}

// MARK: - HashtagFavourite
struct HashtagFavourite: Codable {
    let id, userID, hashtagID: Int
    let created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case hashtagID = "hashtag_id"
        case created
    }
}

// MARK: - User
struct UserFav: Codable {
    let id: Int?
    let firstName, lastName, bio, website: String?
    let profilePic: String?
    let profilePicSmall, profileGIF, deviceToken: String?
    let business, parent: Int?
    let username: String?
    let verified: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case bio, website
        case profilePic = "profile_pic"
        case profilePicSmall = "profile_pic_small"
        case profileGIF = "profile_gif"
        case deviceToken = "device_token"
        case business, parent, username, verified
    }
}
