//
//  EndPointType.swift
//  Tankhaw
//
//  Created by Mac on 21/03/2024.
//

import Foundation

enum HTTPMethods: String {
    case post = "POST"
}

protocol EndPointType {
    var path: String { get }
    var baseURL: String { get }
    var url: URL? { get }
    var method: HTTPMethods { get }
    var body: Encodable? { get }
    var headers: [String: String]? { get }
}
