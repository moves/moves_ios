//
//  FirebaseManager.swift
// //
//
//  Created by Wasiq Tayyab on 08/08/2024.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseStorage

class FirebaseManager {

    static let shared = FirebaseManager()

    static var allFolders: [String] = []
    static var allFiles: [String] = []
    static var fileURLs: [String] = []
    static var isImagePathFound: Bool = false
    static var firebaseURLs: [[String: String]] = []
    static var firstImageURL: String?

    private init() { }

    
    // MARK: - Firebase Realtime Database

    func generateRandomKey(userId: String, completion: @escaping (String) -> Void) {
        let databaseRef = Database.database().reference().child("DishProducts").child(sanitizeFirebasePath(userId)).child("Temp")
        let randomKey = databaseRef.childByAutoId().key ?? UUID().uuidString
        completion(randomKey)
    }

    func deleteUser(userId: String, completion: @escaping (Bool) -> Void) {
        let databaseRef = Database.database().reference().child("DishProducts").child(sanitizeFirebasePath(userId))

        // Removing the userId from DishProducts
        databaseRef.removeValue { error, _ in
            if let error = error {
                print("Error deleting user data: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func storeDataInDatabase(userId: String, data: [String: Any], completion: @escaping (Error?) -> Void) {
        let databaseRef = Database.database().reference().child("DishProducts").child(sanitizeFirebasePath(userId)).child("Temp")
        databaseRef.updateChildValues(data) { error, _ in
            completion(error)
        }
    }

    func getImagePath(userId: String, completion: @escaping (String?) -> Void) {
        let databaseRef = Database.database().reference().child("DishProducts").child(sanitizeFirebasePath(userId)).child("Temp")

        databaseRef.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let imagePath = value["imagesPath"] as? String else {
                completion(nil)
                return
            }
            completion(imagePath)
        } withCancel: { error in
            print("Error fetching image path: \(error.localizedDescription)")
            completion(nil)
        }
    }

    func verifyFolderName(with authToken: String, in path: String, completion: @escaping (Bool, Error?) -> Void) {
        let sanitizedPath = sanitizeFirebasePath(path)
        let storage = Storage.storage()
        let reference = storage.reference(withPath: sanitizedPath)

        reference.listAll { (result, error) in
            if let error = error {
                completion(false, error)
                return
            }

            let foldersMatch = result?.prefixes.contains(where: { prefix in
                let folderName = prefix.name
                return folderName == self.sanitizeFirebasePath(authToken)
            })

            completion(foldersMatch ?? false, nil)
        }
    }

    func listSubfoldersAndFiles(at path: String, imagePath: String, completion: @escaping () -> Void) {
        let sanitizedPath = sanitizeFirebasePath(path)
        let storage = Storage.storage()
        let storageRef = storage.reference().child(sanitizedPath)

        FirebaseManager.allFolders.removeAll()
        FirebaseManager.allFiles.removeAll()
        FirebaseManager.fileURLs.removeAll()
        FirebaseManager.isImagePathFound = false

        func processDirectory(_ ref: StorageReference, completion: @escaping () -> Void) {
            ref.listAll { result, error in
                if let error = error {
                    print("Error listing items: \(error.localizedDescription)")
                    completion()
                    return
                }

                guard let result = result else {
                    print("No result returned from listAll.")
                    completion()
                    return
                }

                let group = DispatchGroup()
                let queue = DispatchQueue(label: "ProcessDirectoryQueue", attributes: .concurrent)

                for prefix in result.prefixes {
                    FirebaseManager.allFolders.append(prefix.fullPath)
                    group.enter()
                    queue.async {
                        processDirectory(prefix) {
                            group.leave()
                        }
                    }
                }

                var fileCount = 0
                for item in result.items {
                    FirebaseManager.allFiles.append(item.fullPath)

                    group.enter()
                    item.downloadURL { url, error in
                        if let error = error {
                            print("Error getting download URL for \(item.fullPath): \(error.localizedDescription)")
                        } else if let url = url, fileCount < 20 {
                            FirebaseManager.fileURLs.append(url.absoluteString)
                            fileCount += 1
                        }
                        group.leave()
                    }
                }

                group.notify(queue: .main) {
                    let imagePathLastComponent = imagePath.split(separator: "/").last ?? ""
                    FirebaseManager.isImagePathFound = FirebaseManager.allFolders.contains(where: { $0.split(separator: "/").last == imagePathLastComponent })
                    completion()
                }
            }
        }

        processDirectory(storageRef) {
            completion()
        }
    }

    func uploadImagesToFirebase(images: [UIImage], imagePath: String, authToken: String, userId: String, completion: @escaping (Result<[String], Error>) -> Void) {
        var downloadURLs: [String] = []
        let dispatchGroup = DispatchGroup()
        
        func uploadImage(at index: Int) {
            guard index < images.count else {
                completion(.success(downloadURLs))
                return
            }
            
            let image = images[index]
            let isFirstImage = (index == 0)
            
            uploadImageToFirebase(image: image, imagePath: imagePath, authToken: authToken, userId: userId, isFirstImage: isFirstImage) { result in
                switch result {
                case .success(let url):
                    downloadURLs.append(url)
                    uploadImage(at: index + 1)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
        uploadImage(at: 0)
    }

    func uploadImageToFirebase(image: UIImage, imagePath: String, authToken: String, userId: String, isFirstImage: Bool, completion: @escaping (Result<String, Error>) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-yyyy"
        let currentDate = dateFormatter.string(from: Date())

        let fileName = UUID().uuidString + ".jpg"
        let filePath = "vendor/\(sanitizeFirebasePath(authToken))/product/\(currentDate)/\(sanitizeFirebasePath(userId))/\(sanitizeFirebasePath(imagePath))/\(fileName)"

        let storage = Storage.storage()
        let storageRef = storage.reference().child(filePath)

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."])))
            return
        }

        let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            storageRef.downloadURL { url, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let downloadURL = url?.absoluteString else {
                    completion(.failure(NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL."])))
                    return
                }

                let imageURLDict: [String: String] = ["image": downloadURL]

                FirebaseManager.firebaseURLs.append(imageURLDict)

                if isFirstImage {
                    FirebaseManager.firstImageURL = downloadURL
                }

                completion(.success(downloadURL))
            }
        }

        uploadTask.observe(.progress) { snapshot in
            // Optional: Handle progress
        }

        uploadTask.observe(.success) { snapshot in
            // Optional: Handle success
        }

        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error {
                completion(.failure(error))
            }
        }
    }

    private func sanitizeFirebasePath(_ path: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ".#$[]")
        return path.components(separatedBy: invalidCharacters).joined(separator: "")
    }
}

private extension StorageReference {
    var name: String {
        return self.fullPath.split(separator: "/").last.map(String.init) ?? ""
    }
}
