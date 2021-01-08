//
//  TabBarController.swift
//  Simple Shopping
//
//  Created by Chris Turner on 05/05/2020.
//  Copyright © 2020 Chris Turner. All rights reserved.
//

import UIKit
import SwiftIcons
import CoreData

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    var listBrain = ListBrain()
    
    var middleBtn = UIButton()
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.delegate = self
    
        
        
        tabBar.items?[0].setIcon(icon: .googleMaterialDesign(.list), size: CGSize(width: 30, height: 30), textColor: .lightGray)
        tabBar.items?[1].setIcon(icon: .emoji(.forkKnifePlate), size: nil, textColor: .lightGray)
    
        tabBar.items?[0].titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -5.0)
        tabBar.items?[1].titlePositionAdjustment = UIOffset(horizontal: -30, vertical: -5.0)
        tabBar.items?[2].titlePositionAdjustment = UIOffset(horizontal: 30, vertical: -5.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(buttonColor), name: NSNotification.Name(rawValue: "buttonColor"), object: nil)
        
        setupMiddleButton()

   }
    
    func setupMiddleButton() {

        middleBtn = UIButton(frame: CGRect(x: (self.view.bounds.width / 2)-25, y: -20, width: 50, height: 50))
        
        //STYLE THE BUTTON YOUR OWN WAY
        middleBtn.setIcon(icon: .fontAwesomeSolid(.plus), iconSize: 20.0, color: UIColor.white, backgroundColor: UIColor(named: "Green")!, forState: .normal)
        middleBtn.layer.cornerRadius = 0.5 * middleBtn.bounds.size.width
        
        
        
//        GRADIENT FOR WHEN YOU WANT IT
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = middleBtn.bounds
//        gradientLayer.cornerRadius = 0.5 * middleBtn.bounds.size.width
//        gradientLayer.colors = [UIColor.yellow.cgColor, UIColor.white.cgColor]
//        middleBtn.layer.insertSublayer(gradientLayer, at: 0)
//        middleBtn.applyGradient(colors: colorBlueDark.cgColor,colorBlueLight.cgColor])
        
        //add to the tabbar and add click event
        self.tabBar.addSubview(middleBtn)
        middleBtn.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)
        middleBtn.bringSubviewToFront(middleBtn)
        self.view.layoutIfNeeded()
    }

    // Menu Button Touch Action
    
    @objc func buttonColor() {
        
        if ListBrain.viewControllerLive == 1 {
            middleBtn.backgroundColor = UIColor(named: "Blue")
            middleBtn.isHidden = false
            middleBtn.isEnabled = true
        } else if ListBrain.viewControllerLive == 0 {
            middleBtn.backgroundColor = UIColor(named: "Green")
            middleBtn.isHidden = false
            middleBtn.isEnabled = true
        } else if ListBrain.viewControllerLive == 3 {
            middleBtn.backgroundColor = UIColor(named: "Green")
            middleBtn.isHidden = false
            middleBtn.isEnabled = true
        } else if ListBrain.viewControllerLive == 2 {
            middleBtn.backgroundColor = UIColor(named: "Green")
            middleBtn.isHidden = false
            middleBtn.isEnabled = true
        } else {
            middleBtn.isHidden = true
            middleBtn.isEnabled = false
        }
    }
    
    @objc func menuButtonAction(sender: UIButton) {
        
        if ListBrain.viewControllerLive == 0 {
            listBrain.addItem(vc: self)
        } else if ListBrain.viewControllerLive == 1 {
            listBrain.addMeal(vc: self)
        } else if ListBrain.viewControllerLive == 2 {
            listBrain.addMealItem(vc: self)
        } else if ListBrain.viewControllerLive == 3 {
            listBrain.addLocation(vc: self)
        }
            
    //        to select the middle tab. use "1" if you have only 3 tabs.
    //        self.selectedIndex = 2
        }
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

            guard let fromView = selectedViewController?.view, let toView = viewController.view else {
              return false // Make sure you want this as false
            }

            if fromView != toView {
                UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.curveEaseIn], completion: nil)
            }

            return true
        }
    
    
    
    
}
