//
//  Item+CoreDataProperties.swift
//  
//
//  Created by Chris Turner on 26/06/2020.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var categoryOfItem: String?
    @NSManaged public var itemName: String?
    @NSManaged public var neededThatWeek: Bool
    @NSManaged public var purchasedThatWeek: Bool
    @NSManaged public var quantity: Int16
    @NSManaged public var selectedThatWeek: Bool
    @NSManaged public var orderOfPurchase: Int16
    @NSManaged public var itemLocation: Location?
    @NSManaged public var parentCategory: Meal?

}
