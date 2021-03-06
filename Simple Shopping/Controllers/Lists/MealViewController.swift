//
//  ViewController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 21/01/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import CoreData

class MealViewController: MasterViewController {
    
    
    //MARK: ViewDidLoad and ViewWillAppear
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listBrain.loadMeals(vc: self)
        
        tableView.reloadData()
        
        title = "Meals"
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMealsList), name: NSNotification.Name(rawValue: "loadMeals"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ListBrain.viewControllerLive = 1
        listBrain.loadMeals(vc: self)
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buttonColor"), object: nil)
    }
    
    //MARK: Notification to Load Meals if something changes
    
    @objc func loadMealsList(notification: NSNotification){
        listBrain.loadMeals(vc: self)
        self.tableView.reloadData()
    }
    
    //MARK: TableView Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = listBrain.fetchedMealsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> MealCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mealCell", for: indexPath) as! MealCell
        
        let meal = listBrain.fetchedMealsController.object(at: indexPath)
        
        var daysSinceMeal: Double = -1
        
        cell.buttonAction = { [self] sender in
            // Do whatever you want from your button here.
            ListBrain.selectedMeal = self.listBrain.fetchedMealsController.object(at: indexPath)
            self.performSegue(withIdentifier: "showMealItems", sender: self)
        }
        
        cell.mealName.text = meal.mealName
        cell.accessoryType = meal.selectedMeal ? .checkmark : .none
        
        //Date last made label
        
        if let isoDate = (listBrain.fetchedMealsController.object(at: indexPath).shoppingTripPurchased?.dateOfShop) {
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: isoDate)
        
        let finalDate = calendar.date(from:components)
        
        let today = Date()
        let delta = today.timeIntervalSince(finalDate!)
        daysSinceMeal = delta/60/60/24
        } else {
            daysSinceMeal = -1
        }

        if daysSinceMeal == -1 {
            cell.lastMade.text = "New Meal"
        } else if daysSinceMeal < 7 {
            cell.lastMade.text = "Last Few Days"
        } else if daysSinceMeal > 7 {
            cell.lastMade.text = "Last Week"
        } else if daysSinceMeal > 14 {
            cell.lastMade.text = "2 Weeks Ago"
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        listBrain.fetchedMealsController.object(at: indexPath).selectedMeal = !listBrain.fetchedMealsController.object(at: indexPath).selectedMeal
        
        let selectedMeal = listBrain.fetchedMealsController.object(at: indexPath)
        var selectedMealsItems = [Item]()
        
        let request : NSFetchRequest<Item> = Item.createFetchRequest()
        
        let predicate = NSPredicate(format: "ANY inMeal.mealName MATCHES %@", selectedMeal.mealName!)
        
        request.predicate = predicate
        
        do {
            selectedMealsItems = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        //If you've just selected the meal
        if listBrain.fetchedMealsController.object(at: indexPath).selectedMeal == true {
            
            for item in selectedMealsItems {
                
                print(item.itemName)
                
                var itemInSelectedMeal = 0
                
                let selectedMeals = item.inMeal?.allObjects as! [Meal]
                if selectedMeals.count != 0 {
                    
                    for meal in selectedMeals {
                        if meal.selectedMeal == true {
                            itemInSelectedMeal += 1
                        }
                    }
                }
                
                //If an item is already a new or staple - Don't change OnShoppingList value
                if item.newOrStaple != nil {
                    
                }
                
                //If an item isn't a new or staple, add to list (Doesn't matter if it's in another meal)
                else if item.newOrStaple == nil {
                    item.onShoppingList = true
                }
            }
        }
        
        //If you've just deselected the meal
        if listBrain.fetchedMealsController.object(at: indexPath).selectedMeal == false {
            
            for item in selectedMealsItems {
                
                var itemInSelectedMeal = 0
                
                let selectedMeals = item.inMeal?.allObjects as! [Meal]
                if selectedMeals.count != 0 {
                    
                    for meal in selectedMeals {
                        if meal.selectedMeal == true {
                            itemInSelectedMeal += 1
                        }
                    }
                }
                
                //If an item is already a new or staple - Don't change OnShoppingList value
                if item.newOrStaple != nil {
                    
                }
                
                //If an item isn't a new or staple, check if it's in any other selected meals - If not, remove/add from list
                else if item.newOrStaple == nil && itemInSelectedMeal != 0 {
                    
                }
                
                else if item.newOrStaple == nil && itemInSelectedMeal == 0 {
                    item.onShoppingList = false
                }
                
            }
        
        }
        listBrain.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.reloadData()
        
    }
        
        //MARK: Swipe Actions
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                
                let selectedMeal = listBrain.fetchedMealsController.object(at: indexPath)
                var selectedMealsItems = [Item]()
                
                let request : NSFetchRequest<Item> = Item.createFetchRequest()
                
                let predicate = NSPredicate(format: "inMeal.mealName MATCHES %@", selectedMeal.mealName!)
                
                request.predicate = predicate
                
                do {
                    selectedMealsItems = try context.fetch(request)
                } catch {
                    print("Error fetching data from context \(error)")
                }
                
                for item in selectedMealsItems {
                    if  item.inMeal!.allObjects.count == 1 && item.newOrStaple == nil && item.shoppingTripPurchased!.count == 0 {
                        context.delete(item)
                    }
                    
                    //if item is only in one meal, not a new or staple and has been purchased - Remove from meal and make invisible
                    if  item.inMeal!.allObjects.count == 1 && item.newOrStaple == nil && item.shoppingTripPurchased!.count == 0 {
                        item.removeFromInMeal(selectedMeal)
                        item.visible = false
                    }
                    
                    //if item is any meal and is a new or staple
                    if  item.inMeal!.allObjects.count != 0 && item.newOrStaple != nil {
                        item.removeFromInMeal(selectedMeal)
                    }
                    
                    //if item is in more than one meal
                    if item.inMeal!.allObjects.count >= 2 {
                        item.removeFromInMeal(selectedMeal)
                    }
                }
                
                context.delete(listBrain.fetchedMealsController.object(at: indexPath))
                listBrain.saveItems()
                listBrain.loadMeals(vc: self)
                tableView.reloadData()
            }
        }
        
    }

