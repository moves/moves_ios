//
//  SoundDetailViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 22/06/2024.
//

import Foundation

final class SoundDetailViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    var showSoundsAgainstSection: HomeResponse?

    func showVideosAgainstSound(parameters: ShowVideosAgainstSoundRequest) {
            APIManager.shared.request(
                modelType: HomeResponse.self,
                type: ProductEndPoint.showVideosAgainstSound(showVideosAgainstSound: parameters)
            ) { result in
                switch result {
                case .success(let showSoundsAgainstSection):
                    self.eventHandler?(.newShowSoundsAgainstSection(showSoundsAgainstSection: showSoundsAgainstSection))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
        }
    
}

extension SoundDetailViewModel {
    enum Event {
        case error(Error?)
        case newShowSoundsAgainstSection(showSoundsAgainstSection: HomeResponse)
    }
}
