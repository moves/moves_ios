//
//  APIManager.swift
//  Tankhaw
//
//  Created by Mac on 21/03/2024.
//
import Foundation

enum DataError: Error {
    case invalidResponse
    case invalidURL
    case invalidData
    case network(Error?)
    case decoding(Error?)
}

typealias ResultHandler<T> = (Result<T, DataError>) -> Void

final class APIManager {

    static let shared = APIManager()
    private let networkHandler: NetworkHandler
    private let responseHandler: ResponseHandler

    init(networkHandler: NetworkHandler = NetworkHandler(),
         responseHandler: ResponseHandler = ResponseHandler()) {
        self.networkHandler = networkHandler
        self.responseHandler = responseHandler
    }
    
    
    func request<T: Codable>(
        modelType: T.Type,
        type: EndPointType,
        completion: @escaping ResultHandler<T>
    ) {
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        request.httpMethod = type.method.rawValue
        request.allHTTPHeaderFields = type.headers
        
        if let parameters = type.body {
            do {
                request.httpBody = try JSONEncoder().encode(parameters)
            } catch {
//                completion(.failure(.encoding(error)))
                return
            }
        }

        networkHandler.requestDataAPI(url: request) { result in
            switch result {
            case .success(let data):
                self.responseHandler.parseResponseDecode(
                    data: data,
                    modelType: modelType
                ) { response in
                    switch response {
                    case .success(let mainResponse):
                        completion(.success(mainResponse))
                    case .failure(let error):
                        completion(.failure(.decoding(error)))
                    }
                }
            case .failure(let error):
                completion(.failure(.network(error)))
            }
        }
    }
    
    static var commonHeaders: [String: String] {
        print("UserDefaultsManager.shared.authToken",UserDefaultsManager.shared.authToken)
        return [
            "Content-Type": "application/json",
            "Api-Key"     : "156c4675-9608-4591-b2ec-xxxxxxx",
            "Auth-Token" : UserDefaultsManager.shared.authToken
        ]
    }
}


class NetworkHandler {

    func requestDataAPI(
        url: URLRequest,
        completionHandler: @escaping (Result<Data, DataError>) -> Void
    ) {
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completionHandler(.failure(.network(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completionHandler(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completionHandler(.failure(.invalidData))
                return
            }
            
            if httpResponse.statusCode == 200 {
                let cachedResponse = CachedURLResponse(response: httpResponse, data: data)
                URLCache.shared.storeCachedResponse(cachedResponse, for: url)
                // Data is now cached
            }
            
            completionHandler(.success(data))
        }
        session.resume()
    }
}

class ResponseHandler {

    func parseResponseDecode<T: Decodable>(
        data: Data,
        modelType: T.Type,
        completionHandler: @escaping ResultHandler<T>
    ) {
        do {
            let decodedResponse = try JSONDecoder().decode(modelType, from: data)
            completionHandler(.success(decodedResponse))
        } catch {
            completionHandler(.failure(.decoding(error)))
        }
    }
}
