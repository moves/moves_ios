//
//  ResponseEntity+CoreDataProperties.swift
//  Moves
//
//  Created by Wasiq Tayyab on 25/10/2024.
//

import Foundation
import CoreData

extension ResponseEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ResponseEntity> {
        return NSFetchRequest<ResponseEntity>(entityName: "ResponseEntity")
    }

    @NSManaged public var responseData: Data?
    @NSManaged public var id: String?
}
