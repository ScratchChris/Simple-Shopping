//
//  LocationsViewController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 14/06/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import CoreData

class LocationsViewController: MasterViewController {

    var listBrain = ListBrain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listBrain.loadLocations(vc: self)
        tableView.reloadData()
        title = "Kitchen Locations"
        
         NotificationCenter.default.addObserver(self, selector: #selector(loadLocations), name: NSNotification.Name(rawValue: "loadLocations"), object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func viewDidAppear(_ animated: Bool) {
                ListBrain.viewControllerLive = 3
    }
    
    @objc func loadLocations(notification: NSNotification){
        listBrain.loadLocations(vc: self)
        self.tableView.reloadData()
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = listBrain.fetchedLocationsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath)
        
        let location = listBrain.fetchedLocationsController.object(at: indexPath)
        
        cell.textLabel?.text = location.locationName
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        
        if editingStyle == .delete {
            
            context.delete(listBrain.fetchedLocationsController.object(at: indexPath))
//                tableView.deleteRows(at: [indexPath], with: .fade)
            listBrain.saveItems()
            listBrain.loadLocations(vc: self)
            tableView.reloadData()
        
            }
    }


}
