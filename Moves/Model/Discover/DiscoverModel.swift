//
//  DiscoverModel.swift
// //
//
//  Created by Wasiq Tayyab on 04/06/2024.
//

import Foundation

// MARK: - DiscoverResponse
struct DiscoverResponse: Codable {
    let code: Int
    var msg: [DiscoverResponseMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([DiscoverResponseMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct DiscoverResponseMsg: Codable {
    let hashtag: MsgHashtag?
    
    enum CodingKeys: String, CodingKey {
        case hashtag = "Hashtag"
    }
}

// MARK: - MsgHashtag
struct MsgHashtag: Codable {
    let id: Int
    let name, views: String
    let videos: [HomeResponseMsg]
    let videosCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, name, views
        case videos = "Videos"
        case videosCount = "videos_count"
    }
}


// MARK: - VideoElement
struct VideoElement: Codable {
    let hashtagVideo: HashtagVideo
    let hashtag: VideoHashtag
    let video: Video?

    enum CodingKeys: String, CodingKey {
        case hashtagVideo = "HashtagVideo"
        case hashtag = "Hashtag"
        case video = "Video"
    }
}

// MARK: - VideoHashtag
struct VideoHashtag: Codable {
    let id: Int?
    let name: String?
    let favourite: Int?
    
    enum CodingKeys: String, CodingKey {
        case id, name, favourite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        favourite = try container.decodeIfPresent(Int.self, forKey: .favourite)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(favourite, forKey: .favourite)
    }
}

// MARK: - HashtagVideo
struct HashtagVideo: Codable {
    let id: Int?
    let hashtagID: Int?
    let videoID: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case hashtagID = "hashtag_id"
        case videoID = "video_id"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        hashtagID = try container.decodeIfPresent(Int.self, forKey: .hashtagID)
        videoID = try container.decodeIfPresent(Int.self, forKey: .videoID)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(hashtagID, forKey: .hashtagID)
        try container.encodeIfPresent(videoID, forKey: .videoID)
    }
}


// MARK: - VideoLike
struct VideoLike: Codable {
    let id, userID, videoID: StringOrInt?
    let user: User?
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case videoID = "video_id"
        case user = "User"
        case created
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(StringOrInt.self, forKey: .id)
        userID = try container.decode(StringOrInt.self, forKey: .userID)
        videoID = try container.decode(StringOrInt.self, forKey: .videoID)
        user = try container.decodeIfPresent(User.self, forKey: .user)
        created = try container.decode(String.self, forKey: .created)
    }
}


// MARK: - VideoComment
struct VideoComment: Codable {
    var id: StringOrInt
    var userID: StringOrInt
    var videoID: StringOrInt
    let comment: String
    let created: String
    var ownerLike: StringOrInt?
    var like: StringOrInt?
    var likeCount: StringOrInt
    var commentID: StringOrInt?
    let user: User?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case videoID = "video_id"
        case comment
        case created
        case ownerLike = "owner_like"
        case like
        case likeCount = "like_count"
        case commentID = "comment_id"
        case user = "User"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(StringOrInt.self, forKey: .id)
        userID = try container.decode(StringOrInt.self, forKey: .userID)
        videoID = try container.decode(StringOrInt.self, forKey: .videoID)
        comment = try container.decode(String.self, forKey: .comment)
        created = try container.decode(String.self, forKey: .created)
        ownerLike = try container.decodeIfPresent(StringOrInt.self, forKey: .ownerLike)
        like = try container.decodeIfPresent(StringOrInt.self, forKey: .like)
        likeCount = try container.decodeIfPresent(StringOrInt.self, forKey: .likeCount) ?? .int(0)
        commentID = try container.decodeIfPresent(StringOrInt.self, forKey: .commentID)
        user = try container.decodeIfPresent(User.self, forKey: .user)
    }
}
