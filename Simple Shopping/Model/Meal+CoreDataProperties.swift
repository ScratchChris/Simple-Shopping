//
//  Meal+CoreDataProperties.swift
//  Simple Shopping
//
//  Created by Chris Turner on 19/06/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//
//

import Foundation
import CoreData


extension Meal {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Meal> {
        return NSFetchRequest<Meal>(entityName: "Meal")
    }

    @NSManaged public var mealName: String
    @NSManaged public var selectedMeal: Bool
    @NSManaged public var mealItems: NSSet

}

// MARK: Generated accessors for mealItems
extension Meal {

    @objc(addMealItemsObject:)
    @NSManaged public func addToMealItems(_ value: Item)

    @objc(removeMealItemsObject:)
    @NSManaged public func removeFromMealItems(_ value: Item)

    @objc(addMealItems:)
    @NSManaged public func addToMealItems(_ values: NSSet)

    @objc(removeMealItems:)
    @NSManaged public func removeFromMealItems(_ values: NSSet)

}
