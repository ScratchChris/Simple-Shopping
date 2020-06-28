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
    
    var listBrain = ListBrain()
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> GoShoppingCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "goShoppingCell", for: indexPath) as! GoShoppingCell
        // set the text from the data model
        
        let item = listBrain.shoppingListArray[indexPath.row]

        cell.itemName.text = item.itemName
        cell.itemType.text = item.categoryOfItem
        cell.quantity.text = String(item.quantity)
        
        
        if item.categoryOfItem == "New" {
            cell.itemType.backgroundColor = UIColor(named: "Green")
        } else if item.categoryOfItem == "Staple" {
            cell.itemType.backgroundColor = UIColor(named: "Yellow")
        } else if item.categoryOfItem == "Meal" {
            cell.itemType.backgroundColor = UIColor(named: "Blue")
        }
        
        cell.accessoryType = item.purchasedThatWeek ? .checkmark : .none

        if item.purchasedThatWeek == true {
            cell.backgroundColor = UIColor.gray
        } else {
            cell.backgroundColor = UIColor.clear
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if listBrain.shoppingListArray[indexPath.row].purchasedThatWeek == false {
        
            listBrain.shoppingListArray[indexPath.row].purchasedThatWeek = !listBrain.shoppingListArray[indexPath.row].purchasedThatWeek
            tableView.deselectRow(at: indexPath, animated: true)
            let element = listBrain.shoppingListArray.remove(at: indexPath.row)
            listBrain.shoppingListArray.append(element)
            
        } else {
            listBrain.shoppingListArray[indexPath.row].purchasedThatWeek = !listBrain.shoppingListArray[indexPath.row].purchasedThatWeek
            let element = listBrain.shoppingListArray.remove(at: indexPath.row)
            listBrain.shoppingListArray.insert(element, at: 0)
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        listBrain.saveItems()
    }
    
    @objc func completeShop() {
        let ac = UIAlertController(title: "Complete Shop", message: "Are you sure?", preferredStyle: .alert)
                
        let yesAction = UIAlertAction(title: "Yes, I've finished", style: .default) { (UIAlertAction) in
            
            //part that sets the sort order of the shop.
            
            var orderOfPurchase: Int16 = 1
            
            for item in self.listBrain.shoppingListArray.reversed() {
                item.orderOfPurchase = orderOfPurchase
                orderOfPurchase += 1
            }
            
            
            //part that resets and deletes all unrequired information
            
            var allMeals = [Meal]()
            var allItems = [Item]()
            
            let itemRequest : NSFetchRequest<Item> = Item.createFetchRequest()
            let mealRequest : NSFetchRequest<Meal> = Meal.createFetchRequest()

            do {
                allItems = try self.context.fetch(itemRequest)
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            do {
                allMeals = try self.context.fetch(mealRequest)
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            for meal in allMeals {
                meal.selectedMeal = false
            }
            
            for item in allItems {
                if item.categoryOfItem == "New" {
                    self.context.delete(item)
                } else if item.categoryOfItem == "Meal" {
                    item.neededThatWeek = false
                    item.selectedThatWeek = false
                    item.purchasedThatWeek = false
                } else {
                    item.neededThatWeek = false
                    item.purchasedThatWeek = false
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


