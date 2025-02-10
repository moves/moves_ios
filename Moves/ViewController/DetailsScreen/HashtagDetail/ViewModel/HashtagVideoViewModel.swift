//
//  HashtagVideoViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 19/06/2024.
//

import Foundation

final class HashtagVideoViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    var showVideosAgainstHashtag: ShowVideosAgainstHashtagResponse?
    var nearby: HomeResponse?
    
    func showVideosAgainstHashtag(parameters: ShowVideosAgainstHashtagRequest) {
        APIManager.shared.request(
            modelType: ShowVideosAgainstHashtagResponse.self,
            type: ProductEndPoint.showVideosAgainstHashtag(showVideosAgainstHashtag: parameters)) { result in
                switch result {
                case .success(let showVideosAgainstHashtag):
                    self.eventHandler?(.newShowVideosAgainstHashtag(showVideosAgainstHashtag: showVideosAgainstHashtag))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func addHashtagFavourite(parameters: AddHashtagFavouriteRequest) {
        APIManager.shared.request(
            modelType: AddHashtagFavouriteResponse.self,
            type: ProductEndPoint.addHashtagFavourite(addHashtagFavourite: parameters)) { result in
                switch result {
                case .success(let addHashtagFavourite):
                    self.eventHandler?(.newAddHashtagFavourite(addHashtagFavourite: addHashtagFavourite))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func showNearbyVideos(parameters: AddHashtagFavouriteRequest) {
        APIManager.shared.request(
            modelType: AddHashtagFavouriteResponse.self,
            type: ProductEndPoint.addHashtagFavourite(addHashtagFavourite: parameters)) { result in
                switch result {
                case .success(let addHashtagFavourite):
                    self.eventHandler?(.newAddHashtagFavourite(addHashtagFavourite: addHashtagFavourite))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func showVideosAgainstLocation(parameters: ShowVideosAgainstLocationRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showVideosAgainstLocation(showVideosAgainstLocation: parameters)) { result in
                switch result {
                case .success(let showVideosAgainstLocation):
                    self.eventHandler?(.newShowVideosAgainstLocation(showVideosAgainstLocation: showVideosAgainstLocation))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    
    
}

extension HashtagVideoViewModel {
    enum Event {
        case error(Error?)
        case newShowVideosAgainstHashtag(showVideosAgainstHashtag: ShowVideosAgainstHashtagResponse)
        case newAddHashtagFavourite(addHashtagFavourite: AddHashtagFavouriteResponse)
        case newShowVideosAgainstLocation(showVideosAgainstLocation: HomeResponse)
    }
}
