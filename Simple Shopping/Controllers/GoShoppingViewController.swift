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
        listBrain.loadCompleteList(vc: self)
        listBrain.loadCompleteListPostShop(vc: self)
        
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
        tableView.reloadData()
        
    }
    
    @objc func completeShop() {
        let ac = UIAlertController(title: "Complete Shop", message: "Are you sure?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes, I've finished", style: .default) { (UIAlertAction) in
            
            //Sets up a new shopping trip for the history
            let newShoppingTrip = ShoppingTrip(context: self.context)
            newShoppingTrip.dateOfShop = Date()
            
            for i in 0...self.listBrain.shoppingListArray.count - 1 {
                
                //Find the purchased item.
                let purchasedItem = self.listBrain.shoppingListArray[i]
                
                let itemBeforeValue: String
                let itemValue: String
                let itemAfterValue : String
                
                let completeItem : Item
                let completeItemAfter : Item?
                let completeItemBefore : Item?
                
                if purchasedItem.purchased == true {
                    
                    //Adds the item to the shopping trip history
                    newShoppingTrip.addToItemsPurchased(purchasedItem)
                    
                    //Finds the original item in the overall list.
                    completeItem = self.listBrain.completeListArray[self.listBrain.completeListArray.firstIndex(of: purchasedItem)!]
                    let purchasedItemShopOrder = i+1
                    let purchasedItemOriginalOrder = completeItem.orderOfPurchase
                    
                    //Works out whether the item bought is higher, lower or the same that the original item.
                    let itemDifference = purchasedItemShopOrder - Int(purchasedItemOriginalOrder)
                    
                    switch itemDifference {
                    case 0  :
                        itemValue = "Same"
                    case _ where itemDifference < 0 :
                        itemValue = "Lower"
                    default:
                        itemValue = "Higher"
                    }
                    
                    //Finds and sets the item before value to Same, Lower, Higher or Nil.
                    if i == 0 { itemBeforeValue = "Nil"
                        completeItemBefore = nil
                        } else {
                        
                        let itemPurchasedBefore = self.listBrain.shoppingListArray[i-1]
                        completeItemBefore = self.listBrain.completeListArray[self.listBrain.completeListArray.firstIndex(of: itemPurchasedBefore)!]
                        let itemPurchasedBeforeShopOrder = i
                            let itemPurchasedBeforeOriginalOrder = Int(completeItemBefore!.orderOfPurchase)
                        
                        let itemBeforeDifference = itemPurchasedBeforeShopOrder - itemPurchasedBeforeOriginalOrder
                        
                        switch itemBeforeDifference {
                        case 0  :
                            itemBeforeValue = "Same"
                        case _ where itemBeforeDifference < 0 :
                            itemBeforeValue = "Lower"
                        default:
                            itemBeforeValue = "Higher"
                        }
                        
                    }
                    
                    //Finds the item after and sets the value to Higher, Lower, Same or Nil
                    if i == self.listBrain.shoppingListArray.count - 1 {
                        itemAfterValue = "Nil"
                        completeItemAfter = nil
                    }
                    else {
                        let itemPurchasedAfter = self.listBrain.shoppingListArray[i+1]
                        completeItemAfter = self.listBrain.completeListArray[self.listBrain.completeListArray.firstIndex(of: itemPurchasedAfter)!]
                        let itemPurchasedAfterShopOrder = i+2
                        let itemPurchasedAfterOriginalOrder = completeItemAfter!.orderOfPurchase
                        
                        let itemAfterDifference = itemPurchasedAfterShopOrder - Int(itemPurchasedAfterOriginalOrder)
                        
                        switch itemAfterDifference {
                        case 0  :
                            itemAfterValue = "Same"
                        case _ where itemAfterDifference < 0 :
                            itemAfterValue = "Lower"
                        default:
                            itemAfterValue = "Higher"
                        }
                    }
                    
                    //Creates a constant that contains the three outputs from the above, which is then dropped into the switch statement to work out which function should be run on the item.
                    let itemAssessment = (itembefore: itemBeforeValue, item : itemValue, itemAfter: itemAfterValue)
                    
                    
                    switch itemAssessment {
                    
                    case ("Nil", "Same", "Higher"), ("Same", "Lower", "Higher"), ("Same", "Higher","Same"), ("Same", "Higher", "Lower"), ("Same", "Higher", "Higher"), ("Same", "Higher","Nil"):
                        #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                        //Make +1 of item before, then shuffle on all other items
                        self.changeOrderToPlusOneOfItemBefore(item: completeItem, itemBefore: completeItemAfter!)
                        
                    case ("Nil","Lower","Same"), ("Nil", "Lower", "Higher"), ("Nil", "Higher", "Same"), ("Nil", "Higher", "Lower"):
                        #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
                        //Make same order of item after, then shuffle all other items on
                        self.changeOrderToItemAfter(item: completeItem, itemAfter: completeItemAfter!)
                        
                    case ("Nil", "Higher", "Higher"):
                        #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1)
                       //Keep going through items until it finds one with an order, then back populate all new items, then shuffle pack on
                        self.findItemWithOrderAfter(item: completeItem)
                       
                    default:
                       
                        //Don't need to do anything at all for this one.
                        print("Default")
                        
                    }
                    
                } else {
                    //ignore as item was not purchased
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
                
                item.tickedOnList = false
                item.purchased = false
                
                
                if item.newOrStaple == "New" {
                    item.visible = false
                    item.onShoppingList = false
                } else if item.newOrStaple == "Staple" {
                    
                } else {
                    item.onShoppingList = false
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
    
    func changeOrderToPlusOneOfItemBefore(item : Item, itemBefore : Item) {
        
    }
    
    func changeOrderToItemAfter(item : Item, itemAfter: Item) {
        
    }
    
    func findItemWithOrderAfter(item : Item) {
        
    }
    
    //                if purchasedItem.purchased == true {
    //
    //                    //Adds the item to the shopping trip history
    //                    newShoppingTrip.addToItemsPurchased(purchasedItem)
    //
    //                    //Finds the original item
    //                    let completeItem = self.listBrain.completeListArray[self.listBrain.completeListArray.firstIndex(of: purchasedItem)!]
    //
    //                    //If the item has never been bought before.
    //                    if completeItem.orderOfPurchase == 0 {
    //
    //                        //Sets the order of purchase to where it was bought in the shop + 1
    //                        completeItem.orderOfPurchase = Int16(orderInShop)
    //
    //
    //                        var newOrder = Int(completeItem.orderOfPurchase) + 1
    //                        if completeItem.orderOfPurchase != self.listBrain.completeListArray.count {
    //                            for i in Int(completeItem.orderOfPurchase) ..< self.listBrain.completeListArray.count - 1 {
    //                                if self.listBrain.completeListArray[i].orderOfPurchase == 0 {
    //
    //                                } else {
    //                                self.listBrain.completeListArray[i].orderOfPurchase = Int16(newOrder)
    //                                newOrder += 1
    //                                }
    //                                self.listBrain.saveItems()
    //                            }
    //                        } else {
    //
    //                        }
    //
    //                    //If it has been bought before section
    //
    //                    //If original order of purchase is higher than where it was bought in the shop.
    //                    } else if completeItem.orderOfPurchase > orderInShop {
    //
    //                        //Bananas was at position 4, but instead has been bought 3rd.
    //
    //                        if i == 0 {
    //                            //very first item bought, so cannot check items before it in the purchased list
    //
    //                            //find the item bought after it in the original list
    //                            let itemAfter = self.listBrain.shoppingListArray[i+1]
    //                            let completeItemAfter = self.listBrain.completeListArray[self.listBrain.completeListArray.firstIndex(of: itemAfter)!]
    //
    //                            //if the item bought after also has original order of purchase as higher
    //                            if i+1 < completeItemAfter.orderOfPurchase {
    //                                //leave the number as it is
    //                            } else {
    //                                //item after has a lower original order and is a change of order.
    //                            }
    //
    //
    //                        } else {
    //
    //                            //find the item bought before it in the original list
    //                            let itemBefore = self.listBrain.shoppingListArray[i - 1]
    //                            let completeItemBefore = self.listBrain.completeListArray[self.listBrain.completeListArray.firstIndex(of: itemBefore)!]
    //
    //                            //if the item bought before the item in question also has original order of purchase as higher
    //                            if i-1 < completeItemBefore.orderOfPurchase {
    //                                //leave the number as it is
    //                            } else {
    //
    //                                //if the item bought before has a lower original order of purchase, this confuses things, that is a change of order.
    //
    //                            completeItem.orderOfPurchase = completeItemBefore.orderOfPurchase + 1
    //                            var newOrder = Int(completeItem.orderOfPurchase) + 1
    //                            for i in Int(completeItem.orderOfPurchase) ..< self.listBrain.completeListArray.count - 1 {
    //
    //                                self.listBrain.completeListArray[i].orderOfPurchase = Int16(newOrder)
    //                                newOrder += 1
    //                            }
    //                            }
    //
    //                        }
    //                    }
    //
    //
    //                    else if completeItem.orderOfPurchase < orderInShop {
    //
    //                        //If original order of purchase is lower than where it was bought in the shop.
    //
    //                        //Bananas was at position 3, but has now been purchased 4th.
    //
    //                        //Leave the same for now, but need to work on code to assess if the shop has moved around based on other items purchased
    //
    //
    //                    }
    //
    //                } else {  }
    
}


