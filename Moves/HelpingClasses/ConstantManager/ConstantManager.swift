//
//  DishManager.swift
// //
//
//  Created by Wasiq Tayyab on 10/08/2024.
//

import Foundation
import FirebaseStorage
import UIKit
import FirebaseFunctions


class ConstantManager {
    static let shared = ConstantManager()
    
    private init() {}
    static var editImagePath = ""
    static var productId = ""

    static var dishName = ""
    static var descriptionDish = ""
    static var ingredientsDish = ""
    static var servingUnit = ""
    static var price = ""
    static var dishOrderLimit = ""
    static var orderHours = ""
    
    
    static var lat = ""
    static var lng = ""
    static var isNotification = false
    static var functionJson: [String: Any] = [:]
    static var isStore = false
    static var isFunctionError = false
    static var storeID = ""
    static var isSwitchAccountFlow = false
    static var profileUser: ProfileResponse?
    static var isFetchProduct = false
    static var showRelatedVideos: HomeResponse?
    static var readyForOrder: HomeResponse?
    static var showNearbyVideos: HomeResponse?
    static var showFollowingVideos: HomeResponse?
    static var showCards: PaymentMethodResponse?
    static var hashtagVideo: DiscoverResponse?
    
   
    
    static func productReset() {
        ConstantManager.editImagePath = ""
        ConstantManager.productId = ""
        
        ConstantManager.dishName = ""
        ConstantManager.descriptionDish = ""
        ConstantManager.ingredientsDish = ""
        ConstantManager.servingUnit = ""
        ConstantManager.price = ""
        ConstantManager.dishOrderLimit = ""
        ConstantManager.orderHours = ""
    }
    
    func resetDishDetails() {
        ConstantManager.lat = ""
        ConstantManager.lng = ""
        ConstantManager.profileUser = nil
        ConstantManager.isStore = false
        ConstantManager.showCards = nil
        ConstantManager.dishOrderLimit = ""
        ConstantManager.dishName = ""
        ConstantManager.descriptionDish = ""
        ConstantManager.ingredientsDish = ""
        ConstantManager.servingUnit = ""
        ConstantManager.price = ""
        ConstantManager.orderHours = ""
    }
    
    func uploadVideoToFirebase(fileURL: URL){
        lazy var functions = Functions.functions()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let currentMiliTime =  Int64(Date().timeIntervalSince1970 * 1000)
        let videoRef = storageRef.child("temp/\(currentMiliTime).mp4")
        
        let uploadTask = videoRef.putFile(from: fileURL, metadata: nil) { [weak self] metadata, error in
            guard metadata != nil else {
                print("Error uploading video to firbase: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            videoRef.downloadURL { [weak self] url, error in
                guard let downloadURL = url else {
                    print("Failed to get download URL from firbase: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                print("Video uploaded successfully. Download URL: \(downloadURL)")
                DispatchQueue.main.async {
                    print("Firebase downloadURL",downloadURL)
                    
                    let data: [String: Any] = ["videoUrl": downloadURL.absoluteString]
                    functions.httpsCallable("generateVideoSummary").call(data) { [weak self] result, error in
                        if let error = error as NSError? {
                            ConstantManager.isFunctionError = true
                            print("Error calling generateVideoSummary: \(error.localizedDescription)")
                            return
                        }
                        
                        print("result?.data as? [String: Any] ?? [:]",result?.data as? [String: Any] ?? [:])
                        ConstantManager.functionJson = [:]
                        ConstantManager.functionJson = result?.data as? [String: Any] ?? [:]
                    }
                    
                }
            }
        }
        
        uploadTask.observe(.progress) { [weak self]snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress?.completedUnitCount ?? 0) / Double(snapshot.progress?.totalUnitCount ?? 1)
            
            print("Firebase Upload progress: \(percentComplete)%")
        }
        
        uploadTask.observe(.success) { [weak self]snapshot in
            print("Firebase Upload completed successfully")
        }
        
        uploadTask.observe(.failure) {[weak self] snapshot in
            if let error = snapshot.error {
                print("Upload failed with error: \(error.localizedDescription)")
            }
        }
        
    }
    
    func saveImagesToStorage(imagesData : Data,completion:@escaping(_ status:Bool,_ response:String)->Void) {
        
        let timeStamp = Int(NSDate().timeIntervalSince1970 * 1000)
        
        Storage.storage().reference().child("vendor/\(UserDefaultsManager.shared.authToken).jpeg").putData(imagesData, metadata: nil) { [weak self] (metaData, error) in
            
            guard error == nil else {
                completion(false, error?.localizedDescription ?? "Error")
                return
            }
            Storage.storage().reference().child("vendor/\(UserDefaultsManager.shared.authToken).jpeg").downloadURL { [weak self] (url, error) in
                guard error == nil else {
                    completion(false, error?.localizedDescription ?? "Error")
                    return
                }
                let url = url?.absoluteString ?? ""
                completion(true, url)
            }
        }
    }
    func saveVideoIThumbnailToStorage(imagesData : Data,completion:@escaping(_ status:Bool,_ response:String)->Void) {
        
        let currentMiliTime =  Int64(Date().timeIntervalSince1970 * 1000)
        
        Storage.storage().reference().child("video/\(UserDefaultsManager.shared.authToken)/\(currentMiliTime).jpeg").putData(imagesData, metadata: nil) {[weak self]  (metaData, error) in
            
            guard error == nil else {
                completion(false, error?.localizedDescription ?? "Error")
                return
            }
            Storage.storage().reference().child("video/\(UserDefaultsManager.shared.authToken)/\(currentMiliTime).jpeg").downloadURL { [weak self] (url, error) in
                guard error == nil else {
                    completion(false, error?.localizedDescription ?? "Error")
                    return
                }
                let url = url?.absoluteString ?? ""
                completion(true, url)
            }
        }
    }
  
    
    private lazy var keyboardToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([flexibleSpace, doneButton], animated: false)
        
        return toolbar
    }()
    
    func getKeyboardToolbar() -> UIToolbar {
        return keyboardToolbar
    }
    
    @objc private func doneButtonTapped() {
        UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.endEditing(true)
    }
    
}

