//
//  HomeViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 30/05/2024.
//
enum HomeResponseType: String {
    case related
    case nearby
    case following
    case readyForOrder
}
import Foundation

final class HomeViewModel {
    static let shared = HomeViewModel()
    
    var eventHandler: ((_ event: Event) -> Void)?

    // Properties for storing responses
    var showRelatedVideos: HomeResponse?
    var readyForOrder: HomeResponse?
    var showNearbyVideos: HomeResponse?
    var showFollowingVideos: HomeResponse?
    var showVideoDetail: ShowVideoDetailResponse?
    var showVideoFullDetail: ShowVideoDetailResponse?

    // Fetch related videos
    func showRelatedVideos(parameters: HomeRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showRelatedVideos(showRelatedVideos: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.newShowRelatedVideos(showRelatedVideos: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    // Fetch ready for order
    func readyForOrder(parameters: HomeRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showRelatedVideos(showRelatedVideos: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.newReadyForOrder(readyForOrder: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    // Fetch nearby videos
    func showNearbyVideos(parameters: ShowNearbyVideosRequest) {
        
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showNearbyVideos(showNearbyVideos: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.newShowNearbyVideos(showNearbyVideos: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    // Fetch following videos
    func showFollowingVideos(parameters: ShowFollowingVideosRequest) {
        APIManager.shared.request(
            modelType: HomeResponse.self,
            type: ProductEndPoint.showFollowingVideos(showFollowingVideos: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.newShowFollowingVideos(showFollowingVideos: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    // Like video
    func likeVideo(parameters: LikeVideoRequest) {
        APIManager.shared.request(
            modelType: LikeVideoResponse.self,
            type: ProductEndPoint.likeVideo(likeVideo: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.newLikeVideo(likeVideo: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    // Add video to favorites
    func addVideoFavourite(parameters: LikeVideoRequest) {
        APIManager.shared.request(
            modelType: AddVideoFavouriteResponse.self,
            type: ProductEndPoint.addVideoFavourite(addVideoFavourite: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.newAddVideoFavourite(addVideoFavourite: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    // Fetch video detail
    func showVideoDetail(parameters: LikeVideoRequest) {
        APIManager.shared.request(
            modelType: ShowVideoDetailResponse.self,
            type: ProductEndPoint.showVideoDetail(showVideoDetail: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.newShowVideoDetail(showVideoDetail: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }

    // Fetch full video detail
    func showVideoDetail2(parameters: LikeVideoRequest) {
        APIManager.shared.request(
            modelType: ShowVideoDetailResponse.self,
            type: ProductEndPoint.showVideoDetail(showVideoDetail: parameters)
        ) { result in
            switch result {
            case .success(let response):
                self.eventHandler?(.ShowVideoDetail2(showVideoDetail: response))
            case .failure(let error):
                self.eventHandler?(.error(error))
            }
        }
    }
  
    var homeResponse: HomeResponse?
    var dataArray:[HomeResponseMsg]?
    func preloadNearby() {
        let url = "/showNearbyVideos"
        let parameters :[String: Any] = [
                "user_id":UserDefaultsManager.shared.user_id,
                "device_id":UserDefaultsManager.shared.device_token,
                "long":UserDefaultsManager.shared.longitude,
                "lat":UserDefaultsManager.shared.latitude,
                "starting_point":0
            ] as [String : Any]
        
        NetworkManager.shared.post(endpoint: url, parameters: parameters) { (result: Result<HomeResponse, Error>) in
            switch result {
            case .success(let homeResonse):
                self.homeResponse = homeResonse
                let list = homeResonse.msg ?? []
                
                self.dataArray = list
                
                // preload and cache video thumbnails or gifs
                for item in list {
                    if let video = item.video {
                        let urlString = video.user_thumbnail?.isEmpty == false ? video.user_thumbnail : video.default_thumbnail ?? ""
                        DataPersistence.shared.cachePreload(urlString: urlString ?? "")
                    }
                }

            case .failure(let error):
                print("Error: \(error)")
            }
        }
        
    }
}

extension HomeViewModel {
    enum Event {
        case error(Error?)
        case newShowRelatedVideos(showRelatedVideos: HomeResponse)
        case newShowNearbyVideos(showNearbyVideos: HomeResponse)
        case newShowFollowingVideos(showFollowingVideos: HomeResponse)
        case newLikeVideo(likeVideo: LikeVideoResponse)
        case newAddVideoFavourite(addVideoFavourite: AddVideoFavouriteResponse)
        case newShowVideoDetail(showVideoDetail: ShowVideoDetailResponse)
        case ShowVideoDetail2(showVideoDetail: ShowVideoDetailResponse)
        case newReadyForOrder(readyForOrder: HomeResponse)
    }
}
extension Int16 {
    func toInt() -> Int {
        return Int(self)
    }
}
