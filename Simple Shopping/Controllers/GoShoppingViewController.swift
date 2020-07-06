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
        cell.itemType.text = item.newOrStaple
        cell.quantity.text = String(item.quantity)
        
        
        if item.newOrStaple == "New" {
            cell.itemType.backgroundColor = UIColor(named: "Green")
        } else if item.newOrStaple == "Staple" {
            cell.itemType.backgroundColor = UIColor(named: "Yellow")
        } else if item.newOrStaple == "Meal" {
            cell.itemType.backgroundColor = UIColor(named: "Blue")
        }
        
        cell.accessoryType = item.purchased ? .checkmark : .none

        if item.purchased == true {
            cell.backgroundColor = UIColor.gray
        } else {
            cell.backgroundColor = UIColor.clear
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if listBrain.shoppingListArray[indexPath.row].purchased == false {
        
            listBrain.shoppingListArray[indexPath.row].purchased = !listBrain.shoppingListArray[indexPath.row].purchased
            tableView.deselectRow(at: indexPath, animated: true)
            let element = listBrain.shoppingListArray.remove(at: indexPath.row)
            listBrain.shoppingListArray.append(element)
            
        } else {
            listBrain.shoppingListArray[indexPath.row].purchased = !listBrain.shoppingListArray[indexPath.row].purchased
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
        
            let mealRequest : NSFetchRequest<Meal> = Meal.createFetchRequest()

            do {
                allMeals = try self.context.fetch(mealRequest)
            } catch {
                print("Error fetching data from context \(error)")
            }
            
            for meal in allMeals {
                meal.selectedMeal = false
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


