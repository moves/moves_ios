//
//  NotificaitonViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 05/06/2024.
//

import Foundation

final class NotificaitonViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    var allNotification: NotificationReponse?
    
    func showAllNotifications(parameters: NotificationRequest) {
        APIManager.shared.request(
            modelType: NotificationReponse.self,
            type: ProductEndPoint.showAllNotifications(showAllNotifications: parameters)) { result in
                switch result {
                case .success(let showAllNotifications):
                    self.eventHandler?(.newShowAllNotifications(showAllNotifications: showAllNotifications))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func followUser(parameters: FollowUserRequest) {
        APIManager.shared.request(
            modelType: FollowUserResponse.self,
            type: ProductEndPoint.followUser(followUser: parameters)) { result in
                switch result {
                case .success(let followUser):
                    self.eventHandler?(.newFollowUser(followUser: followUser))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

    func readNotification(parameters: SettingRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.readNotification(readNotification: parameters)) { result in
                switch result {
                case .success(let readNotification):
                    self.eventHandler?(.newReadNotification(readNotification: readNotification))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}

extension NotificaitonViewModel {
    enum Event {
        case error(Error?)
        case newShowAllNotifications(showAllNotifications: NotificationReponse)
        case newFollowUser(followUser: FollowUserResponse)
        case newReadNotification(readNotification: VerifyPhoneNoResponse)
    }
}
