//
//  ReportDescriptionVideoResponse.swift
// //
//
//  Created by Wasiq Tayyab on 23/09/2024.
//

import Foundation

// MARK: - ReportDescriptionVideoResponse
struct ReportDescriptionVideoResponse: Codable {
    let code: Int
    var msg: ReportDescriptionVideoMsg?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case code, msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)

        if code == 200 {
            msg = try? container.decode(ReportDescriptionVideoMsg.self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ReportDescriptionVideoMsg: Codable {
    let reportVideo: ReportVideo
    let user: HomeUser
    let video: Video

    enum CodingKeys: String, CodingKey {
        case reportVideo = "ReportVideo"
        case user = "User"
        case video = "Video"
    }
}

// MARK: - ReportVideo
struct ReportVideo: Codable {
    let id, userID, videoID: Int
    let reportReasonTitle: String
    let reportReasonID: Int
    let description, created: String

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case videoID = "video_id"
        case reportReasonTitle = "report_reason_title"
        case reportReasonID = "report_reason_id"
        case description, created
    }
}

