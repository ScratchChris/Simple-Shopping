//
//  CustomItemCell.swift
//  Smart Shopping 2
//
//  Created by Chris Turner on 21/09/2019.
//  Copyright © 2019 Coding From Scratch. All rights reserved.
//

import UIKit

class CustomItemCell: UITableViewCell {
    
    @IBOutlet weak var itemName: UILabel!
    @IBOutlet weak var itemType: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    
    var plusAction: ((Any) -> Void)?
    var minusAction: ((Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemType.layer.masksToBounds = true
        itemType.layer.cornerRadius = 5

    }
    @IBAction func plusTapped(_ sender: UIButton) {
        self.plusAction?(sender)
    }
    
    @IBAction func minusTapped(_ sender: UIButton) {
        self.minusAction?(sender)
    }
    
}
