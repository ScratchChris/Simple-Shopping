//
//  Location+CoreDataClass.swift
//  Simple Shopping
//
//  Created by Chris Turner on 19/06/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Location)
public class Location: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        print("Init called!")
    }
}
