//
//  CustomItemCell.swift
//  Smart Shopping 2
//
//  Created by Chris Turner on 21/09/2019.
//  Copyright © 2019 Coding From Scratch. All rights reserved.
//

import UIKit

class MealCell: UITableViewCell {
    
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var lastMade: UILabel!
    
    var buttonAction: ((Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lastMade.layer.masksToBounds = true
        lastMade.layer.cornerRadius = 5

    }
    
    @IBAction func editButtonPressed(_ sender: Any) {
        self.buttonAction?(sender)
    }
    
}
