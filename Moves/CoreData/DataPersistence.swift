//
//  ImagePersistence.swift
// //
//
//  Created by Elliott Staffer on 9/20/24.
//

import Foundation
import UIKit
import CoreData

class DataPersistence {
    
    public static let shared = DataPersistence()
    
    public static let modelName = "DataPersisted"

    public init() {
    }

    // create the main context
    public lazy var mainContext: NSManagedObjectContext = {
      return storeContainer.viewContext
    }()

    // create a container
    lazy var storeContainer: NSPersistentContainer = {
       let container = NSPersistentContainer(name: "SmashVideos")
        
        container.loadPersistentStores(completionHandler: { (_, error) in
            guard let error = error as NSError? else { return }
            fatalError("Unresolved error: \(error), \(error.userInfo)")
        })
        
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
        
        return container
    }()

    /// Loads data from CoreData or saves it as `DataPersisted` by url.
    ///
    /// ```
    /// DataPersistence.shared.cacheLoad(urlString: video.thumSmall ?? "") { result in
    ///     switch(result) {
    ///     case .success(let data):
    ///         self.imgView.image = UIImage(data: data)
    ///     case .failure(let error):
    ///         print(error)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameter urlString: A `String` for the url from the backend that has been stored locally in CoreData as binary data.
    /// - Returns A `Result` with a `Data` object or an `Error`.
    func cacheLoad(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        if let url = URL(string: urlString) {
            
            if let existing = getDataPersisted(urlString: urlString) {
                completion(.success(existing.data!))
                return
            } else {
                let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
                // get image data from url
                URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    
                    DispatchQueue.main.async {
                        if let data = data {
                            
                            do {
                                //save to core data
                                let toSave = DataPersisted(context: Self.shared.mainContext)
                                toSave.url = urlString
                                toSave.data = data
                                try Self.shared.mainContext.save()
                                
                            } catch {
                                completion(.failure(error))
                            }
                            
                            completion(.success(data))
                        }
                    }
                }).resume()
            }
        }
    }
    
    /// Loads data from CoreData or saves it as `DataPersisted` by url.
    ///
    /// ```
    /// do {
    ///     let data = try await DataPersistence.shared.cacheLoad(urlString: video.thumSmall ?? "")
    ///     self.imgView.image = UIImage(data: data)
    /// } catch {
    ///     print(error)
    /// }
    /// ```
    ///
    /// - Parameter urlString: A `String` for the url from the backend that has been stored locally in CoreData as binary data.
    /// - Returns: A `Data` object containing the loaded data.
    /// - Throws: An error if the data cannot be loaded or saved.
    func cacheLoad(urlString: String) async throws -> Data {
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL string"])
        }
        
        if let existing = getDataPersisted(urlString: urlString) {
            return existing.data ?? Data()
        } else {
            let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            
            do {
                // Save to core data
                try await Self.shared.mainContext.perform {
                    let toSave = DataPersisted(context: Self.shared.mainContext)
                    toSave.url = urlString
                    toSave.data = data
                    try Self.shared.mainContext.save()
                }
            } catch {
                throw NSError(domain: "CoreDataSaveError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to save data to Core Data: \(error.localizedDescription)"])
            }
            
            return data
        }
    }
    
    /// Preloads and caches data from a given URL string.
    ///
    /// This function attempts to download and cache data from the provided URL. If the data already exists in the cache,
    /// it skips the download. The function is designed for preloading purposes and does not return the downloaded data.
    ///
    /// - Parameter urlString: A string representation of the URL to preload and cache.
    ///
    /// - Note: This function performs the following steps:
    ///   1. Validates the URL string.
    ///   2. Checks if the data already exists in the cache.
    ///   3. If not cached, downloads the data using a URL request.
    ///   4. Saves the downloaded data to Core Data for future use.
    ///
    /// - Warning: Errors during the process are printed to the console but not propagated to the caller.
    ///
    /// - Important: This function is asynchronous and does not provide a completion handler. It's suitable for preloading
    ///   scenarios where immediate access to the data is not required.
    ///
    /// Example usage:
    /// ```
    /// DataPersistence.shared.cachePreload(urlString: "https://example.com/image.jpg")
    /// ```
    func cachePreload(urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Bad url passed to cachePreload: \(urlString)")
            return
        }
        
        if Self.shared.getDataPersisted(urlString: urlString) != nil {
            // Data already exists in cache, no need to download
            return
        }
        
        let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            
            DispatchQueue.main.async {
                if let data = data {
                    
                    do {
                        //save to core data
                        let toSave = DataPersisted(context: Self.shared.mainContext)
                        toSave.url = urlString
                        toSave.data = data
                        try Self.shared.mainContext.save()
                        
                    } catch {
                        print("Error saving to CoreData at cachePreload: \(error)")
                    }
                }
            }
        }).resume()
    }

    /// Preloads and caches data from a given URL string in the background.
    ///
    /// This function attempts to download and cache data from the provided URL in a background queue. If the data already exists in the cache,
    /// it skips the download. The function is designed for preloading purposes and does not return the downloaded data.
    ///
    /// - Parameters:
    ///   - urlString: A string representation of the URL to preload and cache.
    ///   - priority: The quality of service (QoS) for the background task. Defaults to `.userInteractive`.
    ///
    /// - Note: This function performs the following steps:
    ///   1. Validates the URL string.
    ///   2. Checks if the data already exists in the cache.
    ///   3. If not cached, downloads the data using a URL request.
    ///   4. Saves the downloaded data to Core Data for future use.
    ///
    /// - Warning: Errors during the process are printed to the console but not propagated to the caller.
    ///
    /// - Important: This function is asynchronous and does not provide a completion handler. It's suitable for preloading
    ///   scenarios where immediate access to the data is not required.
    ///
    /// - SeeAlso: `DispatchQoS.QoSClass`, `URLSession`, `CoreData`
    ///
    /// # Example Usage
    /// ```swift
    /// DataPersistence.shared.cachePreloadInBackground(urlString: "https://example.com/image.jpg")
    /// ```
    ///
    /// To specify a different priority:
    /// ```swift
    /// DataPersistence.shared.cachePreloadInBackground(urlString: "https://example.com/image.jpg", priority: .background)
    /// ```
    func cachePreloadInBackground(urlString: String, priority: DispatchQoS.QoSClass = .userInteractive) {
        DispatchQueue.global(qos: priority).async {
            guard let url = URL(string: urlString) else {
                print("Bad url passed to cachePreload: \(urlString)")
                return
            }
            
            if Self.shared.getDataPersisted(urlString: urlString) != nil {
                // Data already exists in cache, no need to download
                return
            }
            
            let urlRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
            
            URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                if let data = data {
                    do {
                        // Save to core data
                        let backgroundContext = Self.shared.storeContainer.newBackgroundContext()
                        backgroundContext.perform {
                            let toSave = DataPersisted(context: backgroundContext)
                            toSave.url = urlString
                            toSave.data = data
                            do {
                                try backgroundContext.save()
                            } catch {
                                print("Error saving to CoreData at cachePreload: \(error)")
                            }
                        }
                    }
                }
            }.resume()
        }
    }
    
    /// Get a `DataPersisted` object by url.
    ///
    /// ```
    /// let dataPersisted = try DataManager.getDataPersisted(urlString: urlString)
    /// ```
    ///
    /// - Parameter urlString: A `String` for the url from the backend that has been stored locally in CoreData as binary data.
    /// - Returns A `DataPersisted` object.
    func getDataPersisted(urlString: String) -> DataPersisted? {
        do {
            // create the request
            let request = DataPersisted.fetchRequest() as NSFetchRequest<DataPersisted>

            // filter the request
            let predicate = try createPredicate(key: DataPersistedProperty.url.rawValue, predicateOperator: .equals, value: urlString)
            request.predicate = predicate

            // execute request
            let found = try Self.shared.mainContext.fetch(request)

            return found.first
        } catch {
            return nil
        }
    }
    
    func clear() {
        do {
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: DataPersistence.modelName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)

            try Self.shared.mainContext.execute(deleteRequest)
            try Self.shared.mainContext.save()
        } catch let error as NSError {
            print("DataPersistence could not clear: \(error), \(error.userInfo)")
        }
    }
    
    // MARK: - Codable Data Persistence Functions
    
    func saveToCoreData<T: Codable>(data: T, withId id: String) {
        do {
            let encodedData = try JSONEncoder().encode(data)
            let entity = ResponseEntity(context: mainContext)
            entity.responseData = encodedData
            entity.id = id // Save the unique identifier
            
            try mainContext.save()
            print("Data saved successfully with ID: \(id)")
        } catch {
            print("Failed to save data: \(error)")
        }
    }
    
    func saveOrUpdateCoreData<T: Codable & Equatable>(data: T, withId id: String) {
        do {
            let fetchRequest: NSFetchRequest<ResponseEntity> = ResponseEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %@", id)
            
            let results = try mainContext.fetch(fetchRequest)
            
            if let existingEntity = results.first {
                if let existingData = try? JSONDecoder().decode(T.self, from: existingEntity.responseData ?? Data()) {
                    if existingData != data {
                        existingEntity.responseData = try JSONEncoder().encode(data)
                        try mainContext.save()
                        print("Data updated successfully with ID: \(id)")
                    } else {
                        print("No changes detected. Data remains the same.")
                    }
                }
            } else {
                let newEntity = ResponseEntity(context: mainContext)
                newEntity.responseData = try JSONEncoder().encode(data)
                newEntity.id = id
                try mainContext.save()
                print("New data saved successfully with ID: \(id)")
            }
        } catch {
            print("Failed to save or update data: \(error)")
        }
    }

    
    func fetchFromCoreData<T: Codable>(withId id: String) -> T? {
        let fetchRequest: NSFetchRequest<ResponseEntity> = ResponseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id) // Filter by ID
        
        do {
            let results = try mainContext.fetch(fetchRequest)
            if let responseData = results.first?.responseData {
                let decodedData = try JSONDecoder().decode(T.self, from: responseData)
                return decodedData
            }
        } catch {
            print("Failed to fetch or decode data: \(error)")
        }
        
        return nil
    }
    
    func deleteEntity(withId id: String, context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<ResponseEntity> = ResponseEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id) // Use the id to find the entity

        do {
            let results = try context.fetch(fetchRequest)
            if let entityToDelete = results.first {
                context.delete(entityToDelete) // Delete the fetched entity
                try context.save() // Save the context after deletion
                print("Entity deleted successfully.")
            } else {
                print("No entity found with the given ID.")
            }
        } catch {
            print("Failed to delete entity: \(error)")
        }
    }

    // MARK: Common functions

    /// Creates a type-safe predicate.
    ///
    /// ```
    /// // where request is an NSFetchRequest
    /// let predicate = createPredicate(key: TourProperty.id.rawValue, predicateOperator: .EQUALS, value: id)
    /// request.predicate = predicate
    /// ```
    ///
    /// - Parameter key: A `String` representing the key to sort by.
    /// - Parameter predicateOperator: A `CoreDataPredicateOperator` constant based on Apple's [Predicate Format String Syntax](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html)
    /// - Parameter value: A `Any` object of the value to match by.
    /// - Parameter endValue: A optional `Any` object of the end value of a range for a `.between` `predicateOperator`. Defaults to `nil`.
    /// - Returns An `NSPredicate` to filter with.
    private func createPredicate(key: String, predicateOperator: CoreDataPredicateOperator, value: Any, endValue: Any? = nil) throws -> NSPredicate {

        /// create a predicate for a `.between` operator
        if predicateOperator == .between {
            if let end = endValue {
                let range = [value, end]
                return NSPredicate(format: "\(key) \(predicateOperator.rawValue) \(range)")
            } else {
                throw DataManagerError.noEndValueForBetweenPredicate
            }
        } else if endValue != nil {
            throw DataManagerError.endValueSetForNonBetweenOperator
        }

        /// create a basic predicate for basic comparison or string comparison
        return NSPredicate(format: "\(key) \(predicateOperator.rawValue) '\(value)'")
    }

    /// Deletes an object from local CoreData store.
    ///
    /// ```
    /// try Self.shared.delete(object)
    /// ```
    ///
    internal func delete(_ object: NSManagedObject) throws {
        do {
            Self.shared.mainContext.delete(object)
            try Self.shared.mainContext.save()
        } catch {
            throw error
        }
    }
}

/// Constants based on Apple's [Predicate Format String Syntax](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html)
/// - Important: Only operators for basic comparisons and string comparisons. Other operators not yet implemented.
enum CoreDataPredicateOperator: String {
    // basic comparisons
    case notEqual = "!="
    case equals = "="
    case equalsOrGreaterThan = "=>"
    case equalsOrLessThan = "=<"
    case greaterThan = ">"
    case lessThan = "<"
    case between = "BETWEEN"

    // string comparisons
    case beginsWith = "BEGINSWITH"
    case contains = "CONTAINS"
    case endsWith = "ENDSWITH"
    case like = "LIKE"
    case matches = "MATCHES"
//    case utiConformsTo = "UTI-CONFORMS-TO"
//    case utiEquals = "UTI-EQUALS"
}

/// Custom error constants for `DataManager` with human readable error messages.
enum DataManagerError: String, Error {
    case notFound = "Not found."
    case noEndValueForBetweenPredicate = "No end value for `BETWEEN` predicate."
    case endValueSetForNonBetweenOperator = "End value set for a predicate operator other than `BETWEEN`."
    case outOfRange = "Index out of collection's range."
    case objectCastingError = "Object could not be correctly cast."
}

/// Constants for `ImagePersisted` CoreData entity
enum DataPersistedProperty: String {
    case url
    case data
}
