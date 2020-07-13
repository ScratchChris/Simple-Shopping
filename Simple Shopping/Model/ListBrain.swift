//
//  ListBrain.swift
//  Simple Shopping
//
//  Created by Chris Turner on 19/06/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct ListBrain {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var fetchedItemsController: NSFetchedResultsController<Item>!
    var fetchedMealsController: NSFetchedResultsController<Meal>!
    var fetchedLocationsController: NSFetchedResultsController<Location>!
    var fetchedShoppingTripsController: NSFetchedResultsController<ShoppingTrip>!
    var container: NSPersistentContainer!
    
    static var selectedMeal : Meal?
    
    static var selectedShop : ShoppingTrip?
    
    var shoppingListArray = [Item]()
    
    static var viewControllerLive = 0
    
    //MARK: Save Items
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving content")
        }
    }
    
    //MARK: Loading Items/Meals Methods
    
    mutating func loadShoppingList(vc: UITableViewController) {
        
        if fetchedItemsController == nil {
            let request = Item.createFetchRequest()
            let sort = NSSortDescriptor(key: "itemLocation.locationName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedItemsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "itemLocation.locationName", cacheName: nil)
            fetchedItemsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }

        let predicate = NSPredicate(format: "visible == true && onShoppingList == true ")
        
        fetchedItemsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedItemsController.performFetch()
        } catch {
            print("Fetch failed")
        }
        
    }
    
    mutating func loadMeals(vc: UITableViewController) {
        
        if fetchedItemsController == nil {
            let request = Meal.createFetchRequest()
            //did say mealname
            let sort = NSSortDescriptor(key: "shoppingTripPurchased.dateOfShop", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedMealsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "shoppingTripPurchased.dateOfShop", cacheName: nil)
            
//            fetchedMealsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedMealsController.delegate = vc as? NSFetchedResultsControllerDelegate
            
        }
        
        do {
            try fetchedMealsController.performFetch()
        } catch {
            print("Fetch failed")
        }
    }
    
    mutating func loadMealItems(vc: UITableViewController) {
        
        if fetchedItemsController == nil {
            let request = Item.createFetchRequest()
            let sort = NSSortDescriptor(key: "itemLocation.locationName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedItemsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "itemLocation.locationName", cacheName: nil)
            fetchedItemsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }
        let predicate = NSPredicate(format: "ANY inMeal.mealName = %@  && visible = true" , ListBrain.selectedMeal!.mealName!)
        
        fetchedItemsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedItemsController.performFetch()
        } catch {
            print("Fetch failed")
        }
        
    }
    
    mutating func loadLocations(vc: UITableViewController) {
        
        if fetchedLocationsController == nil {
            let request = Location.createFetchRequest()
            let sort = NSSortDescriptor(key: "locationName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedLocationsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedLocationsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }
        
        do {
            try fetchedLocationsController.performFetch()
        } catch {
            print("Fetch failed")
        }
    }
    
    mutating func loadGoShopping(vc: UITableViewController) {
        
        var unsortedList = [Item]()
        
        let request : NSFetchRequest<Item> = Item.createFetchRequest()
        request.predicate = NSPredicate(format: "tickedOnList == true")

        do {
            unsortedList = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        for item in unsortedList {
            item.purchased = false
        }
        
        shoppingListArray = unsortedList.sorted(by: {$0.orderOfPurchase < $1.orderOfPurchase})
        
    }
    
    mutating func loadPreviousShops(vc: UITableViewController) {
        
        if fetchedShoppingTripsController == nil {
        
        let request : NSFetchRequest<ShoppingTrip> = ShoppingTrip.createFetchRequest()
        let sort = NSSortDescriptor(key: "dateOfShop", ascending: false)
        request.sortDescriptors = [sort]
        request.fetchBatchSize = 20
            
        fetchedShoppingTripsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedShoppingTripsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }
    
    do {
        try fetchedShoppingTripsController.performFetch()
    } catch {
        print("Fetch failed")
    }
    }
    
    mutating func loadPreviousShopItems(vc: UITableViewController) {
        
        if fetchedItemsController == nil {
            let request = Item.createFetchRequest()
            let sort = NSSortDescriptor(key: "itemLocation.locationName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedItemsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "itemLocation.locationName", cacheName: nil)
            fetchedItemsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }
        let predicate = NSPredicate(format: "ANY shoppingTripPurchased.dateOfShop = %@" , ListBrain.selectedShop!.dateOfShop! as CVarArg)
        
        fetchedItemsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedItemsController.performFetch()
        } catch {
            print("Fetch failed")
        }
        
    }
    
    //MARK: Adding Items/Meals Methods
    
    mutating func addItem(vc : TabBarController) {
        
        let ac = UIAlertController(title: "Add New Item", message: "Enter the name of the item and then press on the location", preferredStyle: .alert)
        ac.addTextField()
        
        var locationArray = [Location]()
        
        let request : NSFetchRequest<Location> = Location.createFetchRequest()

        do {
            locationArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        for location in locationArray {
            let submitAction = UIAlertAction(title: location.locationName, style: .default) {
                [self, ac] _ in
                guard let enteredItem = ac.textFields?[0].text else { return }
                
                //Checks to see if the item is already listed somewhere
                let itemRequest : NSFetchRequest<Item> = Item.createFetchRequest()
                itemRequest.predicate = NSPredicate(format: "itemName = %@", enteredItem)
            
                do {
                    let fetchedItems = try context.fetch(itemRequest)
                    
                    //If something else is already made, and in a meal somewhere
                    if fetchedItems.count != 0 && fetchedItems[0].visible == true && fetchedItems[0].inMeal?.allObjects.count != 0 {
                        fetchedItems[0].newOrStaple = "New"
                        fetchedItems[0].itemLocation = location
                        fetchedItems[0].onShoppingList = true
                        self.saveItems()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadShoppingList"), object: nil)
                    }
                    
                    //If Item is in the archive
                    else if fetchedItems.count != 0 && fetchedItems[0].visible == false {
                        fetchedItems[0].visible = true
                        fetchedItems[0].newOrStaple = "New"
                        fetchedItems[0].onShoppingList = true
                        fetchedItems[0].itemLocation = location
                        
                    }
                    
                    //Already is in list as a staple or as a new item
                    else if fetchedItems.count != 0 && fetchedItems[0].visible == true && fetchedItems[0].newOrStaple != nil {
                    print("Item is already in as a staple or as a new item")
                    }
                    else {
                    
                        let newItem = Item(context: self.context)
                        
                        newItem.itemName = enteredItem
                        newItem.newOrStaple = "New"
                        newItem.visible = true
                        newItem.onShoppingList = true
                        newItem.purchased = false
                        newItem.itemLocation = location
                        newItem.orderOfPurchase = 0
                        
                        self.saveItems()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadShoppingList"), object: nil)
                    }
                } catch {
                    print(error)
                }
                
            }
            ac.addAction(submitAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        vc.present(ac, animated: true)
        
    }
    
    mutating func addMeal(vc: TabBarController) {
        
        let ac = UIAlertController(title: "Enter New Meal", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Add", style: .default) {
            [self, weak ac] _ in
            guard let enteredItem = ac?.textFields?[0].text else { return }
            
            let newMeal = Meal(context: self.context)
            newMeal.mealName = enteredItem
            newMeal.selectedMeal = false
            
            self.saveItems()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMeals"), object: nil)

        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(cancelAction)
        
        ac.addAction(submitAction)
        vc.present(ac, animated: true)
    
    }
    
    mutating func addMealItem(vc: TabBarController) {
        
        let ac = UIAlertController(title: "Enter New Item", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        var locationArray = [Location]()
        
        let request : NSFetchRequest<Location> = Location.createFetchRequest()

        do {
            locationArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
                
        for location in locationArray {
            let submitAction = UIAlertAction(title: location.locationName, style: .default) {
                [self, ac] _ in
                guard let enteredItem = ac.textFields?[0].text else { return }
                
                //Checks to see if the item is already listed somewhere
                let itemRequest : NSFetchRequest<Item> = Item.createFetchRequest()
                itemRequest.predicate = NSPredicate(format: "itemName = %@", enteredItem)
            
                do {
                    let fetchedItems = try context.fetch(itemRequest)
                    
                    //If Item is already made, and visible in lists
                    if fetchedItems.count != 0 && fetchedItems[0].visible == true {
                        fetchedItems[0].addToInMeal(ListBrain.selectedMeal!)
                        fetchedItems[0].itemLocation = location
                        self.saveItems()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMealItems"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadShoppingList"), object: nil)
                    }
                    
                    //If Item is in the archive
                    else if fetchedItems.count != 0 && fetchedItems[0].visible == false {
                        fetchedItems[0].addToInMeal(ListBrain.selectedMeal!)
                        fetchedItems[0].visible = true
                        fetchedItems[0].newOrStaple = nil
                        if ListBrain.selectedMeal?.selectedMeal == true {
                            fetchedItems[0].onShoppingList = true
                        } else {
                            fetchedItems[0].onShoppingList = false
                        }
                        fetchedItems[0].itemLocation = location
                        self.saveItems()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMealItems"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadShoppingList"), object: nil)
                        
                    }
                    
                    else {
                    
                        let newItem = Item(context: self.context)
                        
                        newItem.itemName = enteredItem
                        newItem.newOrStaple = nil
                        newItem.visible = true
                        if ListBrain.selectedMeal?.selectedMeal == true {
                            newItem.onShoppingList = true
                        } else {
                            newItem.onShoppingList = false
                        }
                        newItem.purchased = false
                        newItem.itemLocation = location
                        newItem.orderOfPurchase = 0
                        newItem.addToInMeal(ListBrain.selectedMeal!)
                        
                        self.saveItems()
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMealItems"), object: nil)
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadShoppingList"), object: nil)
                    }
                } catch {
                    print(error)
                }
            }
            ac.addAction(submitAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        vc.present(ac, animated: true)
    }
    
    mutating func addLocation(vc: TabBarController) {
        
        let ac = UIAlertController(title: "Enter New Kitchen Location", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Add", style: .default) {
            [self, weak ac] _ in
            guard let enteredItem = ac?.textFields?[0].text else { return }
            
            let newLocation = Location(context: self.context)
            newLocation.locationName = enteredItem
            
            self.saveItems()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadLocations"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadList"), object: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        ac.addAction(submitAction)
        vc.present(ac, animated: true)
        
    }
    
    
    
}
