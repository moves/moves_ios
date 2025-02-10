//
//  CommentViewModel.swift
// //
//
//  Created by Wasiq Tayyab on 03/07/2024.
//

import Foundation

final class CommentViewModel {
    var eventHandler: ((_ event: Event) -> Void)?
    var postCommentOnVideo: CommentResponse?
    var showVideoComments: CommentResponse?
    
    func postCommentOnVideo(parameters: PostCommentRequest) {
        APIManager.shared.request(
            modelType: PostCommentResponse.self,
            type: ProductEndPoint.postCommentOnVideo(postCommentOnVideo: parameters)) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let postCommentOnVideo):
                    self.eventHandler?(.newPostCommentOnVideo(postCommentOnVideo: postCommentOnVideo))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }

    
    func showVideoComments(parameters: CommentRequest) {
        APIManager.shared.request(
            modelType: CommentResponse.self,
            type: ProductEndPoint.showVideoComments(showVideoComments: parameters)) { result in
                switch result {
                case .success(let showVideoComments):
                    self.eventHandler?(.newShowVideoComments(showVideoComments: showVideoComments))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func likeComment(parameters: LikeCommentRequest) {
        APIManager.shared.request(
            modelType: LikeCommentResponse.self,
            type: ProductEndPoint.likeComment(likeComment: parameters)) { result in
                switch result {
                case .success(let likeComment):
                    self.eventHandler?(.newLikeComment(likeComment: likeComment))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func deleteVideoComment(parameters: DeleteVideoCommentRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.deleteVideoComment(deleteVideoComment: parameters)) { result in
                switch result {
                case .success(let deleteVideoComment):
                    self.eventHandler?(.newDeleteVideoComment(deleteVideoComment: deleteVideoComment))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func postCommentReply(parameters: PostCommentReplyRequest) {
        APIManager.shared.request(
            modelType: PostCommentResponse.self,
            type: ProductEndPoint.postCommentReply(postCommentReply: parameters)) { result in
                switch result {
                case .success(let postCommentReply):
                    self.eventHandler?(.newPostCommentReply(postCommentReply: postCommentReply))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func likeReplyComments(parameters: LikeReplyCommentsRequest) {
        APIManager.shared.request(
            modelType: LikeCommentResponse.self,
            type: ProductEndPoint.likeReplyComments(likeReplyComments: parameters)) { result in
                switch result {
                case .success(let likeReplyComments):
                    self.eventHandler?(.newLikeReplyComments(likeReplyComments: likeReplyComments))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
    func deleteVideoCommentReply(parameters: DeleteVideoCommentRequest) {
        APIManager.shared.request(
            modelType: VerifyPhoneNoResponse.self,
            type: ProductEndPoint.deleteVideoCommentReply(deleteVideoCommentReply: parameters)) { result in
                switch result {
                case .success(let deleteVideoCommentReply):
                    self.eventHandler?(.newDeleteVideoCommentReply(deleteVideoCommentReply: deleteVideoCommentReply))
                case .failure(let error):
                    self.eventHandler?(.error(error))
                }
            }
    }
    
}

extension CommentViewModel {
    enum Event {
        case error(Error?)
        case newPostCommentOnVideo(postCommentOnVideo: PostCommentResponse)
        case newShowVideoComments(showVideoComments: CommentResponse)
        case newLikeComment(likeComment: LikeCommentResponse)
        case newDeleteVideoComment(deleteVideoComment: VerifyPhoneNoResponse)
        case newPostCommentReply(postCommentReply: PostCommentResponse)
        case newLikeReplyComments(likeReplyComments: LikeCommentResponse)
        case newDeleteVideoCommentReply(deleteVideoCommentReply: VerifyPhoneNoResponse)
    }
}
