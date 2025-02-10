//
//  SearchVideoModel.swift
// //
//
//  Created by Wasiq Tayyab on 21/05/2024.
//

import Foundation

struct SearchVideoResponse: Codable {
    let code: Int
    var msg: [SearchVideoMsg]?
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case code, msg
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)
        if code == 200 {
            msg = try container.decode([SearchVideoMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct SearchVideoMsg: Codable {
    let video: Video
    let user: HomeUser
    let location: HomeLocation
    let sound: Sound

    enum CodingKeys: String, CodingKey {
        case video = "Video"
        case user = "User"
        case sound = "Sound"
        case location = "Location"
    }
}

// MARK: - Sound
struct Sound: Codable {
    let id: Int?
    let audio: String?
    let duration, name, description: String?
    let thum: String?
    let soundSectionID: Int?
    let uploadedBy: String?
    let publish: Int?
    let jobID, created: String?
    let totalVideos, favourite: Int?
    let selected: Int = 0
    enum CodingKeys: String, CodingKey {
        case id, audio, duration, name, description, thum
        case soundSectionID = "sound_section_id"
        case uploadedBy = "uploaded_by"
        case publish
        case jobID = "job_id"
        case created
        case totalVideos = "total_videos"
        case favourite
        case selected = "selected"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        audio = try container.decodeIfPresent(String.self, forKey: .audio)
        duration = try container.decodeIfPresent(String.self, forKey: .duration)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        thum = try container.decodeIfPresent(String.self, forKey: .thum)
        soundSectionID = try container.decodeIfPresent(Int.self, forKey: .soundSectionID)
        uploadedBy = try container.decodeIfPresent(String.self, forKey: .uploadedBy)
        publish = try container.decodeIfPresent(Int.self, forKey: .publish)
        jobID = try container.decodeIfPresent(String.self, forKey: .jobID)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        totalVideos = try container.decodeIfPresent(Int.self, forKey: .totalVideos)
        favourite = try container.decodeIfPresent(Int.self, forKey: .favourite)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(audio, forKey: .audio)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(thum, forKey: .thum)
        try container.encodeIfPresent(soundSectionID, forKey: .soundSectionID)
        try container.encodeIfPresent(uploadedBy, forKey: .uploadedBy)
        try container.encodeIfPresent(publish, forKey: .publish)
        try container.encodeIfPresent(jobID, forKey: .jobID)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(totalVideos, forKey: .totalVideos)
        try container.encodeIfPresent(favourite, forKey: .favourite)
        try container.encodeIfPresent(selected, forKey: .selected)
    }
}


// MARK: - Video
struct Video: Codable, Equatable {
    static func == (lhs: Video, rhs: Video) -> Bool {
        return lhs.id == rhs.id
    }
    let id: Int?
    let userID: Int?
    let description: String?
    let video: String?
    let thum,user_thumbnail,default_thumbnail: String?
    let gif: String?
    let view: Int?
    let section: String?
    let soundID: Int?
    let privacyType: String?
    let allowComments: String?
    let allowDuet, block, duetVideoID, oldVideoID: Int?
    let duration: Double?
    let promote, pinCommentID, pin, repostUserID: Int?
    let repostVideoID, qualityCheck, viral, story: Int?
    let countryID: Int?
    let city, state, country, region: String?
    let locationString: String?
    let share: Int?
    let videoWithWatermark: String?
    let lat: String?
    let long: String?
    let productID: String?
    let jobID: String?
    let tagProduct, width, tag_store_id,height: Int?
    let aiSummary, aiCategory, aiHashtags: String?
    let aiFilters: String?
    let created: String?
    var like, favourite, repost, favouriteCount: Int?
    var commentCount, likeCount: Int?
    let locationTitle: String?
    
    // New properties from VideoVideo
    let user: HomeUser?
    let sound: Sound?
    let videoComment: [Video]?
    let videoProduct: [VideoProduct]?
    let videoLike: [Video]?
    let location: HomeLocation?
    let locationId: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case default_thumbnail = "default_thumbnail"
        case user_thumbnail = "user_thumbnail"
        case userID = "user_id"
        case description, video, thum
        case thumSmall = "thum_small"
        case gif, view, section
        case soundID = "sound_id"
        case privacyType = "privacy_type"
        case allowComments = "allow_comments"
        case allowDuet = "allow_duet"
        case block
        case duetVideoID = "duet_video_id"
        case oldVideoID = "old_video_id"
        case duration, promote
        case pinCommentID = "pin_comment_id"
        case pin
        case repostUserID = "repost_user_id"
        case repostVideoID = "repost_video_id"
        case qualityCheck = "quality_check"
        case viral, story
        case countryID = "country_id"
        case city, state, country, region
        case locationString = "location_string"
        case share
        case videoWithWatermark = "video_with_watermark"
        case lat, long
        case productID = "product_id"
        case jobID = "job_id"
        case tagProduct = "tag_product"
        case tag_store_id = "tag_store_id"
        case width, height
        case aiSummary = "ai_summary"
        case aiCategory = "ai_category"
        case aiHashtags = "ai_hashtags"
        case aiFilters = "ai_filters"
        case created, like, favourite, repost
        case favouriteCount = "favourite_count"
        case commentCount = "comment_count"
        case likeCount = "like_count"
        case locationTitle = "location_title"
        
        // New properties from VideoVideo
        case user = "User"
        case sound = "Sound"
        case product = "Product"
        case videoComment = "VideoComment"
        case videoProduct = "VideoProduct"
        case videoLike = "VideoLike"
        case locationId = "location_id"
        case location = "Location"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        userID = try container.decodeIfPresent(Int.self, forKey: .userID)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        video = try container.decodeIfPresent(String.self, forKey: .video)
        thum = try container.decodeIfPresent(String.self, forKey: .thum)
        user_thumbnail = try container.decodeIfPresent(String.self, forKey: .user_thumbnail)
//        thumSmall = try container.decodeIfPresent(String.self, forKey: .thumSmall)
        gif = try container.decodeIfPresent(String.self, forKey: .gif)
        view = try container.decodeIfPresent(Int.self, forKey: .view)
        section = try container.decodeIfPresent(String.self, forKey: .section)
        soundID = try container.decodeIfPresent(Int.self, forKey: .soundID)
        privacyType = try container.decodeIfPresent(String.self, forKey: .privacyType)
        allowComments = try container.decodeIfPresent(String.self, forKey: .allowComments)
        allowDuet = try container.decodeIfPresent(Int.self, forKey: .allowDuet)
        block = try container.decodeIfPresent(Int.self, forKey: .block)
        duetVideoID = try container.decodeIfPresent(Int.self, forKey: .duetVideoID)
        oldVideoID = try container.decodeIfPresent(Int.self, forKey: .oldVideoID)
        duration = try container.decodeIfPresent(Double.self, forKey: .duration)
        promote = try container.decodeIfPresent(Int.self, forKey: .promote)
        pinCommentID = try container.decodeIfPresent(Int.self, forKey: .pinCommentID)
        pin = try container.decodeIfPresent(Int.self, forKey: .pin)
        repostUserID = try container.decodeIfPresent(Int.self, forKey: .repostUserID)
        repostVideoID = try container.decodeIfPresent(Int.self, forKey: .repostVideoID)
        qualityCheck = try container.decodeIfPresent(Int.self, forKey: .qualityCheck)
        viral = try container.decodeIfPresent(Int.self, forKey: .viral)
        story = try container.decodeIfPresent(Int.self, forKey: .story)
        countryID = try container.decodeIfPresent(Int.self, forKey: .countryID)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        country = try container.decodeIfPresent(String.self, forKey: .country)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        locationString = try container.decodeIfPresent(String.self, forKey: .locationString)
        share = try container.decodeIfPresent(Int.self, forKey: .share)
        videoWithWatermark = try container.decodeIfPresent(String.self, forKey: .videoWithWatermark)
        lat = try container.decodeIfPresent(String.self, forKey: .lat)
        long = try container.decodeIfPresent(String.self, forKey: .long)
        productID = try container.decodeIfPresent(String.self, forKey: .productID)
        jobID = try container.decodeIfPresent(String.self, forKey: .jobID)
        tagProduct = try container.decodeIfPresent(Int.self, forKey: .tagProduct)
        tag_store_id = try container.decodeIfPresent(Int.self, forKey: .tag_store_id)
        width = try container.decodeIfPresent(Int.self, forKey: .width)
        height = try container.decodeIfPresent(Int.self, forKey: .height)
        aiSummary = try container.decodeIfPresent(String.self, forKey: .aiSummary)
        aiCategory = try container.decodeIfPresent(String.self, forKey: .aiCategory)
        aiHashtags = try container.decodeIfPresent(String.self, forKey: .aiHashtags)
        aiFilters = try container.decodeIfPresent(String.self, forKey: .aiFilters)
        created = try container.decodeIfPresent(String.self, forKey: .created)
        like = try container.decodeIfPresent(Int.self, forKey: .like)
        favourite = try container.decodeIfPresent(Int.self, forKey: .favourite)
        repost = try container.decodeIfPresent(Int.self, forKey: .repost)
        favouriteCount = try container.decodeIfPresent(Int.self, forKey: .favouriteCount)
        commentCount = try container.decodeIfPresent(Int.self, forKey: .commentCount)
        likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount)
        locationTitle = try container.decodeIfPresent(String.self, forKey: .locationTitle)
        default_thumbnail = try container.decodeIfPresent(String.self, forKey: .default_thumbnail)

        // Decode new properties
        user = try container.decodeIfPresent(HomeUser.self, forKey: .user)
        if let sound = try? container.decodeIfPresent(Sound.self, forKey: .sound) {
            self.sound = sound
        } else if let _ = try? container.decodeIfPresent([Sound].self, forKey: .sound) {
            self.sound = nil
        } else {
            self.sound = nil
        }
        videoComment = try container.decodeIfPresent([Video].self, forKey: .videoComment)
        videoProduct = try container.decodeIfPresent([VideoProduct].self, forKey: .videoProduct)
        videoLike = try container.decodeIfPresent([Video].self, forKey: .videoLike)
        locationId = try container.decodeIfPresent(Int.self, forKey: .locationId)
    
        if let location = try? container.decodeIfPresent(HomeLocation.self, forKey: .location) {
            self.location = location
        } else if let _ = try? container.decodeIfPresent([HomeLocation].self, forKey: .location) {
            self.location = nil
        } else {
            self.location = nil
        }
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(userID, forKey: .userID)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(video, forKey: .video)
        try container.encodeIfPresent(thum, forKey: .thum)
//        try container.encodeIfPresent(thumSmall, forKey: .thumSmall)
        try container.encodeIfPresent(user_thumbnail, forKey: .user_thumbnail)
        try container.encodeIfPresent(gif, forKey: .gif)
        try container.encodeIfPresent(view, forKey: .view)
        try container.encodeIfPresent(section, forKey: .section)
        try container.encodeIfPresent(soundID, forKey: .soundID)
        try container.encodeIfPresent(privacyType, forKey: .privacyType)
        try container.encodeIfPresent(allowComments, forKey: .allowComments)
        try container.encodeIfPresent(allowDuet, forKey: .allowDuet)
        try container.encodeIfPresent(block, forKey: .block)
        try container.encodeIfPresent(duetVideoID, forKey: .duetVideoID)
        try container.encodeIfPresent(oldVideoID, forKey: .oldVideoID)
        try container.encodeIfPresent(duration, forKey: .duration)
        try container.encodeIfPresent(promote, forKey: .promote)
        try container.encodeIfPresent(pinCommentID, forKey: .pinCommentID)
        try container.encodeIfPresent(pin, forKey: .pin)
        try container.encodeIfPresent(repostUserID, forKey: .repostUserID)
        try container.encodeIfPresent(repostVideoID, forKey: .repostVideoID)
        try container.encodeIfPresent(qualityCheck, forKey: .qualityCheck)
        try container.encodeIfPresent(viral, forKey: .viral)
        try container.encodeIfPresent(story, forKey: .story)
        try container.encodeIfPresent(countryID, forKey: .countryID)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(locationString, forKey: .locationString)
        try container.encodeIfPresent(share, forKey: .share)
        try container.encodeIfPresent(videoWithWatermark, forKey: .videoWithWatermark)
        try container.encodeIfPresent(lat, forKey: .lat)
        try container.encodeIfPresent(long, forKey: .long)
        try container.encodeIfPresent(productID, forKey: .productID)
        try container.encodeIfPresent(jobID, forKey: .jobID)
        try container.encodeIfPresent(tagProduct, forKey: .tagProduct)
        try container.encodeIfPresent(width, forKey: .width)
        try container.encodeIfPresent(height, forKey: .height)
        try container.encodeIfPresent(aiSummary, forKey: .aiSummary)
        try container.encodeIfPresent(aiCategory, forKey: .aiCategory)
        try container.encodeIfPresent(aiHashtags, forKey: .aiHashtags)
        try container.encodeIfPresent(aiFilters, forKey: .aiFilters)
        try container.encodeIfPresent(created, forKey: .created)
        try container.encodeIfPresent(like, forKey: .like)
        try container.encodeIfPresent(favourite, forKey: .favourite)
        try container.encodeIfPresent(repost, forKey: .repost)
        try container.encodeIfPresent(favouriteCount, forKey: .favouriteCount)
        try container.encodeIfPresent(commentCount, forKey: .commentCount)
        try container.encodeIfPresent(likeCount, forKey: .likeCount)
        try container.encodeIfPresent(locationTitle, forKey: .locationTitle)
        try container.encodeIfPresent(default_thumbnail, forKey: .default_thumbnail)
        
        // Encode new properties
        try container.encodeIfPresent(user, forKey: .user)
        try container.encodeIfPresent(sound, forKey: .sound)
        try container.encodeIfPresent(videoComment, forKey: .videoComment)
        try container.encodeIfPresent(videoProduct, forKey: .videoProduct)
        try container.encodeIfPresent(videoLike, forKey: .videoLike)
        try container.encodeIfPresent(locationId, forKey: .locationId)
        try container.encodeIfPresent(location, forKey: .location)
        
    }
    
    
}
