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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listBrain.loadLocations(vc: self)
        ListBrain.viewControllerLive = 3
        
        title = "Kitchen Locations"
        
         NotificationCenter.default.addObserver(self, selector: #selector(loadLocations), name: NSNotification.Name(rawValue: "loadLocations"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        ListBrain.viewControllerLive = 3
        listBrain.loadLocations(vc: self)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "buttonColor"), object: nil)
    }
    
    //MARK: Notification to Load Meals if something changes
    
    
    
    @objc func loadLocations(notification: NSNotification){
        listBrain.loadLocations(vc: self)
        self.tableView.reloadData()
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("This is the section number \(section)")
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
