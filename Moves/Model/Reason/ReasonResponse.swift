//
//  ReasonResponse.swift
// //
//
//  Created by Wasiq Tayyab on 23/09/2024.
//

import Foundation

// MARK: - ReportResponse
struct ReportResponse: Codable {
    let code: Int
    var msg: [ReportMsg]?
    var message: String?

    enum CodingKeys: String, CodingKey {
        case code, msg
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code = try container.decode(Int.self, forKey: .code)

        if code == 200 {
            msg = try? container.decode([ReportMsg].self, forKey: .msg)
            message = nil
        } else {
            msg = nil
            message = try? container.decode(String.self, forKey: .msg)
        }
    }
}

// MARK: - Msg
struct ReportMsg: Codable {
    let reportReason: ReportReason

    enum CodingKeys: String, CodingKey {
        case reportReason = "ReportReason"
    }
}

// MARK: - ReportReason
struct ReportReason: Codable {
    let id: Int
    let title, created: String
}
