//
//  ReasonViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 23/09/2024.
//

import Foundation

final class ReasonViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    
    func showAllReportReasons() {
        APIManager.shared.request(
            modelType: ReportResponse.self,
            type: ProductEndPoint.showReportReasons) { result in
                switch result {
                case .success(let showReportReasons):
                    self.eventHandler?(.showReportReasons(showReportReasons: showReportReasons))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func reportVideo(parameter: ReportVideoRequest) {
        APIManager.shared.request(
            modelType: ReportDescriptionVideoResponse.self,
            type: ProductEndPoint.reportVideo(reportVideo: parameter)) { result in
                switch result {
                case .success(let reportVideo):
                    self.eventHandler?(.reportVideo(reportVideo: reportVideo))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func reportUser(parameter: ReportVideoRequest) {
        APIManager.shared.request(
            modelType: ReportDescriptionVideoResponse.self,
            type: ProductEndPoint.reportUser(reportUser: parameter)) { result in
                switch result {
                case .success(let repostUser):
                    self.eventHandler?(.repostUser(repostUser: repostUser))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func repostVideo(parameter: DeleteVideoRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.repostVideo(repostVideo: parameter)) { result in
                switch result {
                case .success(let repostVideo):
                    self.eventHandler?(.repostVideo(repostVideo: repostVideo))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}


extension ReasonViewModel {
    enum Event {
        case error(Error?)
        case showReportReasons(showReportReasons: ReportResponse)
        case reportVideo(reportVideo: ReportDescriptionVideoResponse)
        case repostVideo(repostVideo: VerifyPhoneNoResponse)
        case repostUser(repostUser: ReportDescriptionVideoResponse)
    }
}

