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
    
    //MARK: Variables
    
    var listBrain = ListBrain()
    
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
        
        cell.buttonAction = { [self] sender in
                // Do whatever you want from your button here.
            ListBrain.selectedMeal = listBrain.fetchedMealsController.object(at: indexPath)
            self.performSegue(withIdentifier: "showMealItems", sender: self)
            print("Button Pressed")
            print(indexPath)
            }
        
        cell.mealName.text = meal.mealName
        cell.accessoryType = meal.selectedMeal ? .checkmark : .none
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        listBrain.fetchedMealsController.object(at: indexPath).selectedMeal = !listBrain.fetchedMealsController.object(at: indexPath).selectedMeal
        
        listBrain.saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
        
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
                item.visible = false
                item.removeFromInMeal(selectedMeal)
            }
            
            context.delete(listBrain.fetchedMealsController.object(at: indexPath))
            listBrain.saveItems()
            listBrain.loadMeals(vc: self)
            tableView.reloadData()
        }
    }

}

