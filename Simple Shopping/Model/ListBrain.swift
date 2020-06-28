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
    var container: NSPersistentContainer!
    
    var shoppingListArray = [Item]()
    
    static var selectedMeal : Meal?
    
    static var viewControllerLive = 0    
    
    //Saves all items back to CoreData based on updated arrays throughout the app.
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving content")
        }
    }
    
    //Loads the meals into the fetchedMealsController
    mutating func loadMeals(vc: UITableViewController) {
        
        if fetchedItemsController == nil {
            let request = Meal.createFetchRequest()
            let sort = NSSortDescriptor(key: "mealName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedMealsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedMealsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }
        
        do {
            try fetchedMealsController.performFetch()
        } catch {
            print("Fetch failed")
        }
    }
    
    //Loads the meal items into the mealItemArray
    mutating func loadMealItems(vc: UITableViewController) {
        
        if fetchedItemsController == nil {
            let request = Item.createFetchRequest()
            let sort = NSSortDescriptor(key: "itemLocation.locationName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedItemsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "itemLocation.locationName", cacheName: nil)
            fetchedItemsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }
        let predicate = NSPredicate(format: "parentCategory.mealName MATCHES %@", ListBrain.selectedMeal!.mealName)
        
        fetchedItemsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedItemsController.performFetch()
        } catch {
            print("Fetch failed")
        }
        
    }
    
    //Loads the locations into the locationsArray
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
    
    //Loads the shopping list into the fetchedItemsController
    mutating func loadShoppingList(vc: UITableViewController) {
        
        if fetchedItemsController == nil {
            let request = Item.createFetchRequest()
            let sort = NSSortDescriptor(key: "itemLocation.locationName", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedItemsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "itemLocation.locationName", cacheName: nil)
            fetchedItemsController.delegate = vc as? NSFetchedResultsControllerDelegate
        }
        let predicate = NSPredicate(format: "selectedThatWeek == true")
        
        fetchedItemsController.fetchRequest.predicate = predicate
        
        do {
            try fetchedItemsController.performFetch()
        } catch {
            print("Fetch failed")
        }
        
    }
    
    mutating func loadGoShopping(vc: UITableViewController) {
        
        var unsortedList = [Item]()
        
        let request : NSFetchRequest<Item> = Item.createFetchRequest()
        let predicate = NSPredicate(format: "neededThatWeek == true")
        request.predicate = predicate

        do {
            unsortedList = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        for item in unsortedList {
            item.purchasedThatWeek = false
        }
        
        shoppingListArray = unsortedList.sorted(by: {$0.orderOfPurchase > $1.orderOfPurchase})
        
        
//        if fetchedItemsController == nil {
//            let request = Item.createFetchRequest()
//            let sort = NSSortDescriptor(key: "orderOfPurchase", ascending: false)
//            request.sortDescriptors = [sort]
//            request.fetchBatchSize = 20
//
//            fetchedItemsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//            fetchedItemsController.delegate = vc as? NSFetchedResultsControllerDelegate
//        }
//        let predicate = NSPredicate(format: "selectedThatWeek == true")
//
//        fetchedItemsController.fetchRequest.predicate = predicate
//
//        do {
//            try fetchedItemsController.performFetch()
//        } catch {
//            print("Fetch failed")
//        }
    }
    
    //MARK: Adding Items/Meals Methods
    
    //Add Item alertcontroller called when plus button is pressed on Shopping List
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
                
                let newItem = Item(context: self.context)
                newItem.itemName = enteredItem
                newItem.categoryOfItem = "New"
                newItem.selectedThatWeek = true
                newItem.purchasedThatWeek = false
                newItem.itemLocation = location
                newItem.orderOfPurchase = 0
                
                self.saveItems()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadShoppingList"), object: nil)
                
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
                
                let newItem = Item(context: self.context)
                newItem.itemName = enteredItem
                newItem.categoryOfItem = "Meal"
                if ListBrain.selectedMeal?.selectedMeal == true {
                    newItem.selectedThatWeek = true } else {
                        newItem.selectedThatWeek = false
                    }
                newItem.purchasedThatWeek = false
                newItem.parentCategory = ListBrain.selectedMeal!
                newItem.itemLocation = location
                
                self.saveItems()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "loadMealItems"), object: nil)
                
            }
            ac.addAction(submitAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        ac.addAction(cancelAction)
        vc.present(ac, animated: true)
        
        
    }
    
    
    
    
}
