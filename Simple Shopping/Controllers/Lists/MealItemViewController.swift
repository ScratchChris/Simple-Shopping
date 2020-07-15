//
//  ViewController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 21/01/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import CoreData

class MealItemViewController: MasterViewController {

    
    //MARK: ViewDidLoad and ViewWillAppear

    override func viewDidLoad() {
        super.viewDidLoad()
        listBrain.loadMealItems(vc: self)
        title = ListBrain.selectedMeal!.mealName
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "loadMealItems"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ListBrain.viewControllerLive = 2
        listBrain.loadMealItems(vc: self)
        tableView.reloadData()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buttonColor"), object: nil)

    }
    
    //MARK: Notification to load list if something changes
    
    @objc func loadList(notification: NSNotification) {
        listBrain.loadMealItems(vc: self)
        self.tableView.reloadData()
    }
    
    //MARK: TableView Methods
    
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCell", for: indexPath)
        
        let item = listBrain.fetchedItemsController.object(at: indexPath)
        cell.textLabel?.text = item.itemName

        
        return cell
    }
    
    //MARK: Swipe Methods
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            //if item is only in one meal, not a new or staple and never been purchased - Delete forever.
            if (listBrain.fetchedItemsController.object(at: indexPath).inMeal?.allObjects.count)! == 1 && listBrain.fetchedItemsController.object(at: indexPath).newOrStaple == nil && listBrain.fetchedItemsController.object(at: indexPath).shoppingTripPurchased!.count == 0 {
                context.delete(listBrain.fetchedItemsController.object(at: indexPath))
            }
            
            //if item is only in one meal, not a new or staple and has been purchased - Remove from meal and make invisible
            if (listBrain.fetchedItemsController.object(at: indexPath).inMeal?.allObjects.count)! == 1 && listBrain.fetchedItemsController.object(at: indexPath).newOrStaple == nil && listBrain.fetchedItemsController.object(at: indexPath).shoppingTripPurchased!.count == 0 {
                listBrain.fetchedItemsController.object(at: indexPath).removeFromInMeal(ListBrain.selectedMeal!)
                listBrain.fetchedItemsController.object(at: indexPath).visible = false
            }
            
            //if item is any meal and is a new or staple
            if  (listBrain.fetchedItemsController.object(at: indexPath).inMeal?.allObjects.count)! != 0 && listBrain.fetchedItemsController.object(at: indexPath).newOrStaple != nil {
                listBrain.fetchedItemsController.object(at: indexPath).removeFromInMeal(ListBrain.selectedMeal!)
            }
            
            //if item is in more than one meal
            if (listBrain.fetchedItemsController.object(at: indexPath).inMeal?.allObjects.count)! >= 2 {
                listBrain.fetchedItemsController.object(at: indexPath).removeFromInMeal(ListBrain.selectedMeal!)
            }
            
            listBrain.fetchedItemsController.object(at: indexPath).visible = false
            listBrain.fetchedItemsController.object(at: indexPath).removeFromInMeal(ListBrain.selectedMeal!)
            
            listBrain.saveItems()
            listBrain.loadMealItems(vc: self)
            tableView.reloadData()
        }
    }
    
}

