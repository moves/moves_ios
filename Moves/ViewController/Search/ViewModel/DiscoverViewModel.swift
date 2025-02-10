//
//  DiscoverViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 04/06/2024.
//

import Foundation

final class DiscoverViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    var hashtagVideo: DiscoverResponse?
    
    func getVideosData(parameters: DiscoverRequest) {
        APIManager.shared.request(
            modelType: DiscoverResponse.self,
            type: ProductEndPoint.showDiscoverySections(showDiscoverySections: parameters)) { result in
                switch result {
                case .success(let showDiscoverySections):
                    self.eventHandler?(.newShowDiscoverySections(showDiscoverySections: showDiscoverySections))
                   
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}

extension DiscoverViewModel {
    enum Event {
        case error(Error?)
        case newShowDiscoverySections(showDiscoverySections: DiscoverResponse)
    }
}
