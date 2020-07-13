//
//  ViewController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 21/01/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import CoreData
import MobileCoreServices


class ShoppingListViewController: MasterViewController
                                  
//                                  UITableViewDragDelegate, UITableViewDropDelegate
{
    
    //MARK: Variables
    
    var listBrain = ListBrain()

    //MARK: View Did Load/View Will Appear
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        tableView.dragDelegate = self
//        tableView.dropDelegate = self
//        tableView.dragInteractionEnabled = true
    
        listBrain.loadShoppingList(vc: self)
        
        title = "List"
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
    
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Cancel Shop", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Go Shopping!", style: .plain, target: self, action: #selector(goShopping))
        
        self.tabBarController?.tabBar.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadShoppingList"), object: nil)
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        ListBrain.viewControllerLive = 0
        listBrain.loadShoppingList(vc: self)
        tableView.reloadData()
        self.tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buttonColor"), object: nil)
    }
    
    //MARK: Notification to load list if something changes
    
    @objc func loadList(notification: NSNotification){
        listBrain.loadShoppingList(vc: self)
        self.tableView.reloadData()
    }
    
    //MARK: Table View Functions
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return listBrain.fetchedItemsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return listBrain.fetchedItemsController.sections![section].name
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let sectionInfo = listBrain.fetchedItemsController.sections![section]
        return sectionInfo.numberOfObjects
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CustomItemCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customItemCell", for: indexPath) as! CustomItemCell
        
        var itemInSelectedMeal = 0
        
        let item = listBrain.fetchedItemsController.object(at: indexPath)
        let selectedMeals = item.inMeal?.allObjects as! [Meal]
        if selectedMeals.count != 0 {
            
            for meal in selectedMeals {
                if meal.selectedMeal == true {
                    itemInSelectedMeal += 1
                }
            }
        }

        cell.itemName.text = item.itemName
        
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
        
        cell.plusAction = { [self] sender in
                // Do whatever you want from your button here.
            listBrain.fetchedItemsController.object(at: indexPath).quantity += 1
            listBrain.saveItems()
        }
        
        cell.minusAction = { [self] sender in
              //Whatever your minus button did.
            if listBrain.fetchedItemsController.object(at: indexPath).quantity == 1 { return } else {
                listBrain.fetchedItemsController.object(at: indexPath).quantity -= 1
                listBrain.saveItems()
            }
            
        }
    
        cell.accessoryType = item.tickedOnList ? .checkmark : .none
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        listBrain.fetchedItemsController.object(at: indexPath).tickedOnList = !listBrain.fetchedItemsController.object(at: indexPath).tickedOnList
    
        listBrain.saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    //MARK: Swipe Methods
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if listBrain.fetchedItemsController.object(at: indexPath).newOrStaple != nil {
        
            if editingStyle == .delete {
                
                //if the item is not in a meal and has never been purchased - Delete the item completely
                if listBrain.fetchedItemsController.object(at: indexPath).inMeal?.allObjects.count == 0 && listBrain.fetchedItemsController.object(at: indexPath).shoppingTripPurchased!.count == 0 {
                    context.delete(listBrain.fetchedItemsController.object(at: indexPath))
                }
                
                //if the item is not in a meal and has previously been purchased - Hide it from view
                if listBrain.fetchedItemsController.object(at: indexPath).inMeal?.allObjects.count == 0 && listBrain.fetchedItemsController.object(at: indexPath).shoppingTripPurchased!.count != 0 {
                    listBrain.fetchedItemsController.object(at: indexPath).visible = false
                }
                
                //if the item is in a meal also - remove it's new/staple label so it remains in the meal
                if listBrain.fetchedItemsController.object(at: indexPath).inMeal?.allObjects.count != 0 {
                    listBrain.fetchedItemsController.object(at: indexPath).newOrStaple = nil
                }

                listBrain.saveItems()
                listBrain.loadShoppingList(vc: self)
                tableView.reloadData()
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if listBrain.fetchedItemsController.object(at: indexPath).newOrStaple == "New" {
            
            let closeAction = UIContextualAction(style: .normal, title:  "Staple", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                self.listBrain.fetchedItemsController.object(at: indexPath).newOrStaple = "Staple"
                success(true)
                self.listBrain.saveItems()
                self.tableView.reloadData()
                
            })
            closeAction.image = UIImage(named: "tick")
            closeAction.backgroundColor = UIColor(named: "Yellow")
            
            return UISwipeActionsConfiguration(actions: [closeAction])
            
        }   else {
            return nil
        }
    }
    
    //MARK: Go Shopping Button Pressed
    
    @objc func goShopping() {
                
        let ac = UIAlertController(title: "Go Shopping", message: "Are you sure?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes, I'm ready", style: .default) { (UIAlertAction) in
            
            
            
            if let vc = self.storyboard?.instantiateViewController(identifier: "GoShopping") as? GoShoppingViewController {
                
                vc.navigationItem.backBarButtonItem?.title = "Cancel Shop"
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(cancelAction)
        ac.addAction(yesAction)
        
        present(ac, animated: true)
        
    }
    
    //MARK: Drag and Drop Methods
    
//    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
//        print("Started Drag")
//        let item = listBrain.fetchedItemsController.object(at: indexPath)
//        let itemName = item.itemName
//        let categoryOfItem = listBrain.fetchedItemsController.object(at: indexPath).categoryOfItem
//
//        guard let data = itemName!.data(using: .utf8) else { return [] }
//            let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
//
//            return [UIDragItem(itemProvider: itemProvider)]
//    }
//
//    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
//        let destinationIndexPath: IndexPath
//
//        print("got here")
//
//        var locationArray = [Location]()
//
//        if let indexPath = coordinator.destinationIndexPath {
//            destinationIndexPath = indexPath
//        } else {
//            let section = tableView.numberOfSections - 1
//            let row = tableView.numberOfRows(inSection: section)
//            destinationIndexPath = IndexPath(row: row, section: section)
//        }
//
//        // attempt to load strings from the drop coordinator
//        coordinator.session.loadObjects(ofClass: NSString.self) { items in
//            // convert the item provider array to a string array or bail out
//            guard let strings = items as? [String] else { return }
//
//            // create an empty array to track rows we've copied
//            var indexPaths = [IndexPath]()
//
//            let request : NSFetchRequest<Location> = Location.createFetchRequest()
//
//            do {
//                locationArray = try self.context.fetch(request)
//            } catch {
//                print("Error fetching data from context \(error)")
//            }
//
//            // loop over all the strings we received
//            for (index, string) in strings.enumerated() {
//                // create an index path for this new row, moving it down depending on how many we've already inserted
//                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
//
//
//
//                // insert the copy into the correct array
//                let newItem = Item(context: self.context)
//                newItem.itemName = string
//                newItem.categoryOfItem = "New"
//                newItem.selectedThatWeek = true
//                newItem.purchasedThatWeek = false
//                newItem.itemLocation = locationArray[indexPath.section]
//                newItem.orderOfPurchase = 0
//
//                // keep track of this new row
//                indexPaths.append(indexPath)
//            }
//
//            // insert them all into the table view at once
//            tableView.insertRows(at: indexPaths, with: .automatic)
//        }
//    }

    
}

