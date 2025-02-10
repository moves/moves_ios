//
//  StoredImage+CoreDataProperties.swift
// //
//
//  Created by Elliott Staffer on 9/20/24.
//

import Foundation
import CoreData


extension DataPersisted {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DataPersisted> {
        return NSFetchRequest<DataPersisted>(entityName: "DataPersisted")
    }

    @NSManaged public var url: String?
    @NSManaged public var data: Data?

}

extension DataPersisted : Identifiable {

}
