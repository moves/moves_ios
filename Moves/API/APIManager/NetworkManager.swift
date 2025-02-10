//
//  NetworkManager.swift
//  LIVEr
//
//  Created by YS on 2024/8/31.
//

import Foundation
import Alamofire
import FirebaseAuth

extension Error {
    var code: Int {
        return (self as NSError).code
    }
    var localizedDescription: String {
        return (self as NSError).localizedDescription
    }
    
}

//MARK: - old API Manager
class NetworkManager {
    
    static let shared = NetworkManager()
    
    private init() {}
    
    private let baseURL = "https://app.movesapp.io/mobileapp_api/api/"
    
    func get<T: Decodable>(endpoint: String, parameters: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        let url = baseURL + endpoint
        
        AF.request(url,method: .get, parameters: parameters, headers: self.defaultHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func post<T: Decodable>(endpoint: String, parameters: [String: Any]?, completion: @escaping (Result<T, Error>) -> Void) {
        let url = baseURL + endpoint
        print("url",url)
        print("parameters",parameters)
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: self.defaultHeaders()).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("\(url)=====\(parameters)=====\(json)")
                } catch let error {
                    print("Failed to convert Data to JSON: \(error.localizedDescription)")
                }
                
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(model))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func defaultHeaders() -> HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Api-Key": "156c4675-9608-4591-b2ec-xxxxxxx",
            "Auth-Token" : UserDefaultsManager.shared.authToken
        ]
    }
}


public struct API {
    static var checkUserName = "checkUsername"
    static var user = "checkIfUserExistInFirebase"
    static var interestList = "v1/interest-tag/list"

}

//MARK: - New API Manager
class LNetworkManager {
    
    static let shared = LNetworkManager()
    
    private init() {}
    
    private let baseURL = "https://app.movesapp.io/mobileapp_api/api/"
    
    func request<T: Decodable>(method: HTTPMethod = .post,endpoint: String, parameters: [String: Any]? = nil, completion: @escaping (Result<T, Error>) -> Void) {
        let url = baseURL + endpoint
        print("url",url)
        print("parameters",parameters)
        
        if method == .get {
            AF.request(url,method: method, parameters: parameters, headers: defaultHeaders()).responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print("\(url)=====\(json)")
                    } catch let error {
                        print("Failed to convert Data to JSON: \(error.localizedDescription)")
                    }
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            do {
                                let model = try JSONDecoder().decode(T.self, from: data)
                                completion(.success(model))
                            } catch   {
                                completion(.failure(error))
                            }
                        } else if code == 201 { //idToken expired
                            Auth.auth().currentUser?.getIDToken { [weak self] idToken, error in
                                if let error = error {
                                    print("Error getting ID token: \(error.localizedDescription)")
                                    completion(.failure(error))
                                } else if let idToken = idToken {
                                    print("Current ID token: \(idToken)")
                                    UserDefaultsManager.shared.idAuthToken = idToken
                                    UserDefaultsManager.shared.authToken = idToken
                                    self?.request(method: method, endpoint: endpoint, completion: completion)
                                }
                            }
                        } else  {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    let error = NSError(domain: "", code: code, userInfo: [
                                        NSLocalizedDescriptionKey : json["message"] as? String ?? ""
                                    ])
                                    completion(.failure(error))
                                    
                                }
                            } catch  (let error) {
                                completion(.failure(error))
                            }
                        }
                    }
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }

        } else {
            AF.request(url,method: method, parameters: parameters,encoding: JSONEncoding.default, headers: defaultHeaders()).responseData { response in
                print("response",response.result)
                switch response.result {
                case .success(let data):
                    print("data",data)
                    
                    // Attempt to print response as a String
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Response String: \(responseString)")
                    } else {
                        print("Failed to convert response data to String")
                    }

                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: [])
                        print("\(url)=====\(json)")
                    } catch let error {
                        print("Failed to convert Data to JSON: \(error.localizedDescription)")
                    }
                    if let code = response.response?.statusCode {
                        if code == 200 {
                            do {
                                let model = try JSONDecoder().decode(T.self, from: data)
                                completion(.success(model))
                            } catch   {
                                completion(.failure(error))
                            }
                        } else if code == 201 { //idToken expired
                            Auth.auth().currentUser?.getIDToken { [weak self] idToken, error in
                                if let error = error {
                                    print("Error getting ID token: \(error.localizedDescription)")
                                    completion(.failure(error))
                                } else if let idToken = idToken {
                                    print("Current ID token: \(idToken)")
                                    UserDefaultsManager.shared.idAuthToken = idToken
                                    UserDefaultsManager.shared.authToken = idToken
                                    self?.request(method: method, endpoint: endpoint, completion: completion)
                                }
                            }
                        } else  {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                    let error = NSError(domain: "", code: code, userInfo: [
                                        NSLocalizedDescriptionKey : json["message"] as? String ?? ""
                                    ])
                                    completion(.failure(error))
                                    
                                }
                            } catch  (let error) {
                                completion(.failure(error))
                            }
                        }
                    }
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    func defaultHeaders() -> HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Api-Key": "156c4675-9608-4591-b2ec-xxxxxxx",
            "Auth-Token" : UserDefaultsManager.shared.idAuthToken
        ]
    }
}
