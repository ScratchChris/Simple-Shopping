//
//  ShoppingTrip+CoreDataProperties.swift
//  Simple Shopping
//
//  Created by Chris Turner on 24/09/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//
//

import Foundation
import CoreData


extension ShoppingTrip {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ShoppingTrip> {
        return NSFetchRequest<ShoppingTrip>(entityName: "ShoppingTrip")
    }

    @NSManaged public var dateOfShop: Date?
    @NSManaged public var itemsPurchased: NSSet?
    @NSManaged public var mealsPurchased: NSSet?

}

// MARK: Generated accessors for itemsPurchased
extension ShoppingTrip {

    @objc(addItemsPurchasedObject:)
    @NSManaged public func addToItemsPurchased(_ value: Item)

    @objc(removeItemsPurchasedObject:)
    @NSManaged public func removeFromItemsPurchased(_ value: Item)

    @objc(addItemsPurchased:)
    @NSManaged public func addToItemsPurchased(_ values: NSSet)

    @objc(removeItemsPurchased:)
    @NSManaged public func removeFromItemsPurchased(_ values: NSSet)

}

// MARK: Generated accessors for mealsPurchased
extension ShoppingTrip {

    @objc(addMealsPurchasedObject:)
    @NSManaged public func addToMealsPurchased(_ value: Meal)

    @objc(removeMealsPurchasedObject:)
    @NSManaged public func removeFromMealsPurchased(_ value: Meal)

    @objc(addMealsPurchased:)
    @NSManaged public func addToMealsPurchased(_ values: NSSet)

    @objc(removeMealsPurchased:)
    @NSManaged public func removeFromMealsPurchased(_ values: NSSet)

}

extension ShoppingTrip : Identifiable {

}
