//
//  ViewController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 21/01/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import CoreData


class ShoppingListViewController: MasterViewController {
    
    //MARK: Variables
    
    var listBrain = ListBrain()

    //MARK: View Did Load/View Will Appear
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
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
        
        let item = listBrain.fetchedItemsController.object(at: indexPath)

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
        
        cell.itemName.text = item.itemName
        cell.itemType.text = item.categoryOfItem
        cell.quantity.text = String(item.quantity)
        cell.plusButton.tag = indexPath.row
        cell.minusButton.tag = indexPath.row
        
        if item.categoryOfItem == "New" {
            cell.itemType.backgroundColor = UIColor(named: "Green")
        } else if item.categoryOfItem == "Staple" {
            cell.itemType.backgroundColor = UIColor(named: "Yellow")
        } else if item.categoryOfItem == "Meal" {
            cell.itemType.backgroundColor = UIColor(named: "Blue")
        }
        
        cell.accessoryType = item.neededThatWeek ? .checkmark : .none
        
        return cell
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        listBrain.fetchedItemsController.object(at: indexPath).neededThatWeek = !listBrain.fetchedItemsController.object(at: indexPath).neededThatWeek
    
        listBrain.saveItems()
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    //MARK: Swipe Methods
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if listBrain.fetchedItemsController.object(at: indexPath).categoryOfItem != "Meal" {
            if editingStyle == .delete {
                
                
                context.delete(listBrain.fetchedItemsController.object(at: indexPath))
                listBrain.saveItems()
                listBrain.loadShoppingList(vc: self)
                tableView.reloadData()
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if listBrain.fetchedItemsController.object(at: indexPath).categoryOfItem == "New" {
            
            let closeAction = UIContextualAction(style: .normal, title:  "Staple", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                print("OK, \(String(describing: self.listBrain.fetchedItemsController.object(at: indexPath).itemName)) marked as Staple")
                self.listBrain.fetchedItemsController.object(at: indexPath).categoryOfItem = "Staple"
                success(true)
                self.listBrain.saveItems()
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
    
}

