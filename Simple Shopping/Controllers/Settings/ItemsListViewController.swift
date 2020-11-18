//
//  ItemsListViewController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 14/07/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import CoreData

class ItemsListViewController: MasterViewController, UITableViewDragDelegate, UITableViewDropDelegate  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listBrain.loadCompleteList(vc: self)
        
        title = "Reorder Items"
        
        tableView.dragInteractionEnabled = true // Enable intra-app drags for iPhone.
        tableView.dragDelegate = self
        tableView.dropDelegate = self

    }
    
    //MARK: - Drag and Drop
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return listBrain.dragItems(for: indexPath)
    }

    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return listBrain.canHandle(session)
    }

    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        // The .move operation is available only for dragging within a single app.
        if tableView.hasActiveDrag {
            if session.items.count > 1 {
                return UITableViewDropProposal(operation: .cancel)
            } else {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
        } else {
            return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
            
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        print("This is the destination index: \(destinationIndexPath)")
        
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // Consume drag items.
            let stringItems = items as! [String]
            print(stringItems)

            for (_, item) in stringItems.enumerated() {

                
                var selectedItems = [Item]()
                
                let request : NSFetchRequest<Item> = Item.createFetchRequest()
                
                let predicate = NSPredicate(format: "itemName == %@", item)
                
                request.predicate = predicate
                
                do {
                    selectedItems = try self.context.fetch(request)
                } catch {
                    print("Error fetching data from context \(error)")
                }
                
                for item in selectedItems {
                    item.itemLocation = self.listBrain.fetchedItemsController.object(at: IndexPath(row: 0, section: destinationIndexPath.section)).itemLocation
                }
                
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listBrain.completeListItems.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> CustomItemCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customItemCell", for: indexPath) as! CustomItemCell

        let item = listBrain.completeListItems[indexPath.row]
        
        cell.itemName.text = item.itemName
        
        if item.orderOfPurchase == 0 {
            cell.itemType.text = "Never Bought"
        } else {
            cell.itemType.text = String(item.orderOfPurchase)
        }
        
        

        return cell
    }

}
