//
//  Item+CoreDataProperties.swift
//  Simple Shopping
//
//  Created by Chris Turner on 06/07/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var newOrStaple: String?
    @NSManaged public var itemName: String?
    @NSManaged public var tickedOnList: Bool
    @NSManaged public var orderOfPurchase: Int16
    @NSManaged public var purchased: Bool
    @NSManaged public var quantity: Int16
    @NSManaged public var visible: Bool
    @NSManaged public var onShoppingList: Bool
    @NSManaged public var inMeal: NSSet?
    @NSManaged public var itemLocation: Location?
    @NSManaged public var shoppingTripPurchased: NSSet?

}

// MARK: Generated accessors for inMeal
extension Item {

    @objc(addInMealObject:)
    @NSManaged public func addToInMeal(_ value: Meal)

    @objc(removeInMealObject:)
    @NSManaged public func removeFromInMeal(_ value: Meal)

    @objc(addInMeal:)
    @NSManaged public func addToInMeal(_ values: NSSet)

    @objc(removeInMeal:)
    @NSManaged public func removeFromInMeal(_ values: NSSet)

}

// MARK: Generated accessors for shoppingTripPurchased
extension Item {

    @objc(addShoppingTripPurchasedObject:)
    @NSManaged public func addToShoppingTripPurchased(_ value: ShoppingTrip)

    @objc(removeShoppingTripPurchasedObject:)
    @NSManaged public func removeFromShoppingTripPurchased(_ value: ShoppingTrip)

    @objc(addShoppingTripPurchased:)
    @NSManaged public func addToShoppingTripPurchased(_ values: NSSet)

    @objc(removeShoppingTripPurchased:)
    @NSManaged public func removeFromShoppingTripPurchased(_ values: NSSet)

}