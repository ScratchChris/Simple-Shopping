//
//  GoShoppingViewController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 03/06/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import CoreData

class GoShoppingViewController : MasterViewController {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = "Go Shopping"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Finish Shop", style: .plain, target: self, action: #selector(completeShop))
        listBrain.loadGoShopping(vc: self)
        self.tabBarController?.tabBar.isHidden = true

       }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listBrain.shoppingListArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CustomItemCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "goShoppingCell", for: indexPath) as! CustomItemCell
        
        let item = listBrain.shoppingListArray[indexPath.row]
        var itemInSelectedMeal = 0
        
        let selectedMeals = item.inMeal?.allObjects as! [Meal]
        if selectedMeals.count != 0 {
            
            for meal in selectedMeals {
                if meal.selectedMeal == true {
                    itemInSelectedMeal += 1
                }
            }
        }
        
        cell.quantity.text = String(item.quantity)
        cell.itemName.text = item.itemName
        cell.plusButton.isHidden = true
        cell.minusButton.isHidden = true
        

        //In Meal and nothing else
        
        if itemInSelectedMeal != 0 && item.newOrStaple == nil {
            cell.mealPlus.isHidden = true
            cell.newStaplePlus.isHidden = true
            cell.itemType.isHidden = false
            cell.itemType.backgroundColor = UIColor(named: "Blue")
            if itemInSelectedMeal == 1 {
                cell.itemType.text = "\(itemInSelectedMeal) Meal"
            } else {
                cell.itemType.text = "\(itemInSelectedMeal) Meals"
            }
        }
        
        //New Item and nothing else
        else if itemInSelectedMeal == 0 && item.newOrStaple == "New" {
            cell.mealPlus.isHidden = true
            cell.newStaplePlus.isHidden = true
            cell.itemType.isHidden = false
            cell.itemType.backgroundColor = UIColor(named: "Green")
            cell.itemType.text = "New"
        }
        
        //Staple Item and nothing else
        else if itemInSelectedMeal == 0 && item.newOrStaple == "Staple" {
            cell.mealPlus.isHidden = true
            cell.newStaplePlus.isHidden = true
            cell.itemType.isHidden = false
            cell.itemType.backgroundColor = UIColor(named: "Yellow")
            cell.itemType.text = "Staple"
        }
        
        //New Item and in a Meal
        else if itemInSelectedMeal != 0 && item.newOrStaple == "New" {
            cell.itemType.isHidden = true
            
            cell.mealPlus.backgroundColor = UIColor(named: "Blue")
            cell.mealPlus.isHidden = false
            cell.mealPlus.text = "\(itemInSelectedMeal)M"
            
            cell.newStaplePlus.text = "N"
            cell.newStaplePlus.isHidden = false
            cell.newStaplePlus.backgroundColor = UIColor(named: "Green")
        }
        
        //Staple Item and in a meal
        else if itemInSelectedMeal != 0 && item.newOrStaple == "Staple" {
            cell.itemType.isHidden = true
            
            cell.mealPlus.backgroundColor = UIColor(named: "Blue")
            cell.mealPlus.isHidden = false
            cell.mealPlus.text = "\(itemInSelectedMeal) M"
            
            cell.newStaplePlus.text = "S"
            cell.newStaplePlus.isHidden = false
            cell.newStaplePlus.backgroundColor = UIColor(named: "Yellow")
        }
        
        cell.quantity.text = String(item.quantity)
        
        cell.accessoryType = item.purchased ? .checkmark : .none
        
        if item.orderOfPurchase == 0 {
            print("true")
            cell.backgroundColor = UIColor(named: "Red")
        } else {
            cell.backgroundColor = UIColor.clear
        }

        if item.purchased == true {
            cell.backgroundColor = UIColor.gray
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if listBrain.shoppingListArray[indexPath.row].purchased == false {
        
            listBrain.shoppingListArray[indexPath.row].purchased = !listBrain.shoppingListArray[indexPath.row].purchased
            tableView.deselectRow(at: indexPath, animated: true)
            let element = listBrain.shoppingListArray.remove(at: indexPath.row)
            listBrain.shoppingListArray.append(element)
            tableView.deselectRow(at: indexPath, animated: true)

            
        } else {
            listBrain.shoppingListArray[indexPath.row].purchased = !listBrain.shoppingListArray[indexPath.row].purchased
            let element = listBrain.shoppingListArray.remove(at: indexPath.row)
            listBrain.shoppingListArray.insert(element, at: 0)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
//        listBrain.saveItems()
        print("got here")
        tableView.reloadData()
        
    }
    
    @objc func completeShop() {
        let ac = UIAlertController(title: "Complete Shop", message: "Are you sure?", preferredStyle: .alert)
                
        let yesAction = UIAlertAction(title: "Yes, I've finished", style: .default) { (UIAlertAction) in
            
            //part that sets the sort order of the shop.
            let newShoppingTrip = ShoppingTrip(context: self.context)
            newShoppingTrip.dateOfShop = Date()
            
            var orderOfPurchase: Int16 = 1
            
            for item in self.listBrain.shoppingListArray.reversed() {
                
                if self.listBrain.shoppingListArray.firstIndex(of: item)! > item.orderOfPurchase   {
                    print("This item's position has changed")
                    item.orderOfPurchase = Int16(self.listBrain.shoppingListArray.firstIndex(of: item)!)
                } else {
                    print("This items position has stayed the same")
                }
                orderOfPurchase += 1
                
                if item.purchased == true {
                    newShoppingTrip.addToItemsPurchased(item)
                }
            }
            
            
            
            //part that resets and deletes all unrequired information
            
            var allMeals = [Meal]()
        
            let mealRequest : NSFetchRequest<Meal> = Meal.createFetchRequest()

            do {
                allMeals = try self.context.fetch(mealRequest)
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            for meal in allMeals {
                if meal.selectedMeal == true {
                    newShoppingTrip.addToMealsPurchased(meal)
                    meal.selectedMeal = false
                }
                
            }
            
            for item in self.listBrain.shoppingListArray {
                
                if item.newOrStaple == "New" {
                    item.visible = false
                    item.tickedOnList = false
                    item.purchased = false
                } else if item.newOrStaple == "Meal" {
                    item.tickedOnList = false
                    item.visible = false
                    item.purchased = false
                } else {
                    item.tickedOnList = false
                    item.purchased = false
                }
            }
            
            
            self.listBrain.saveItems()
            
            self.navigationController?.popViewController(animated: true)
            
        }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                
                ac.addAction(cancelAction)
                ac.addAction(yesAction)
                
                present(ac, animated: true)
    }
    
}


