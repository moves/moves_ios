//
//  AllSoundViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 08/07/2024.
//

import Foundation

final class AllSoundViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    var allSound: AllSoundResponse?
    var allfavouriteSound: AllFavouriteSoundResponse?

    func showSounds(parameters: ShowSoundsRequest) {
        APIManager.shared.request(
            modelType: AllSoundResponse.self,
            type: ProductEndPoint.showSounds(showSounds: parameters)
        ) { result in
            switch result {
            case .success(let showSoundsAgainstSection):
                self.eventHandler?(.newShowSoundsAgainstSection(showSoundsAgainstSection: showSoundsAgainstSection))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }
    func showFavouriteSounds(parameters: ShowSoundsRequest) {
        APIManager.shared.request(
            modelType: AllFavouriteSoundResponse.self,
            type: ProductEndPoint.showFavouriteSounds(showSounds: parameters)
        ) { result in
            switch result {
            case .success(let showSoundsAgainstUserID):
                self.eventHandler?(.ShowFavouriteSoundsAgainstUserID(showSoundsAgainstSection: showSoundsAgainstUserID))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }
    func AddFavouriteSounds(parameters: addFvrtSoundsRequest) {
        APIManager.shared.request(
            modelType: AllFavouriteSoundResponse.self,
            type: ProductEndPoint.addFavouriteSounds(addFvrtSounds: parameters)
        ) { result in
            switch result {
            case .success(let showSoundsAgainstUserID):
                self.eventHandler?(.TagSoundsAgainstUserID(showSoundsAgainstSection: showSoundsAgainstUserID))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

}

extension AllSoundViewModel {
    enum Event {
        case error(Error?)
        case newShowSoundsAgainstSection(showSoundsAgainstSection: AllSoundResponse)
        case ShowFavouriteSoundsAgainstUserID(showSoundsAgainstSection: AllFavouriteSoundResponse)
        case TagSoundsAgainstUserID(showSoundsAgainstSection: AllFavouriteSoundResponse)
    }
}
