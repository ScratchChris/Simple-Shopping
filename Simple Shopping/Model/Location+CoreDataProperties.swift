//
//  Location+CoreDataProperties.swift
//  Simple Shopping
//
//  Created by Chris Turner on 19/06/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var locationName: String
    @NSManaged public var itemsAtLocation: NSSet

}

// MARK: Generated accessors for itemsAtLocation
extension Location {

    @objc(addItemsAtLocationObject:)
    @NSManaged public func addToItemsAtLocation(_ value: Item)

    @objc(removeItemsAtLocationObject:)
    @NSManaged public func removeFromItemsAtLocation(_ value: Item)

    @objc(addItemsAtLocation:)
    @NSManaged public func addToItemsAtLocation(_ values: NSSet)

    @objc(removeItemsAtLocation:)
    @NSManaged public func removeFromItemsAtLocation(_ values: NSSet)

}
