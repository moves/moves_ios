//
//  SearchViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 21/05/2024.
//

import Foundation

final class SearchViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    var searchVideo: HomeResponse?
    var searchUser: SearchUserResponse?
    var searchSound: SearchSoundResponse?
    var searchHashtag: SearchHashtagResponse?
    var searchStore: SearchStoreResponse?
    
    func searchVideo(parameters: SearchRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.search(search: parameters)) { result in
                switch result {
                case .success(let searchVideo):
                    self.eventHandler?(.newSearchVideo(searchVideo: searchVideo))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    func searchUser(parameters: SearchRequest) {
        APIManager.shared.request(
            modelType: SearchUserResponse.self,
            type: ProductEndPoint.search(search: parameters)) { result in
                switch result {
                case .success(let searchUser):
                    self.eventHandler?(.newSearchUser(searchUser: searchUser))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func searchSound(parameters: SearchRequest) {
        APIManager.shared.request(
            modelType: SearchSoundResponse.self,
            type: ProductEndPoint.search(search: parameters)) { result in

                switch result {
                case .success(let searchSound):
                    self.eventHandler?(.newSearchSound(searchSound: searchSound))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func searchHashtag(parameters: SearchRequest) {
        APIManager.shared.request(
            modelType: SearchHashtagResponse.self,
            type: ProductEndPoint.search(search: parameters)) { result in
            
                switch result {
                case .success(let searchHashtag):
                    self.eventHandler?(.newSearchHashtag(searchHashtag: searchHashtag))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
}

extension SearchViewModel {
    enum Event {
        case error(Error?)
        case newSearchVideo(searchVideo: HomeResponse)
        case newSearchUser(searchUser: SearchUserResponse)
        case newSearchSound(searchSound: SearchSoundResponse)
        case newSearchHashtag(searchHashtag: SearchHashtagResponse)
    }
}
