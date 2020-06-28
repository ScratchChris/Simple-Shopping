//
//  CustomItemCell.swift
//  Smart Shopping 2
//
//  Created by Chris Turner on 21/09/2019.
//  Copyright © 2019 Coding From Scratch. All rights reserved.
//

import UIKit

class GoShoppingCell: UITableViewCell {
    
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemType: UILabel!
    @IBOutlet weak var quantity: UILabel!
    
    override func awakeFromNib() {
        super .awakeFromNib()
        
        itemType.layer.masksToBounds = true
        itemType.layer.cornerRadius = 5
    }
        
        
        
    }

    
    
