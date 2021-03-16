//
//  BottomViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 09/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class BottomViewController: UIViewController {

    @IBOutlet weak var bottomMenu: UIImageView!
    
    var parentController : CenterMenuViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openMenu))
        bottomMenu.addGestureRecognizer(tap)
        bottomMenu.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let parentController = self.parentController {
            print("Parent Controller well.")
            if let handler = parentController.menuHandler {
                print("MenuHandler: \(handler.getMenuType())")
                switch handler.getMenuType() {
                    case .SICOBRO:
                        print("SICOBRO Case")
                        self.view.backgroundColor = .black
                    
                    case .BANNERS:
                        self.view.backgroundColor = UIColor(named: "helperColor")
                }
            }
        }
    }
    
    @objc func openMenu() {
        if let parentController = self.parentController {
            parentController.openLeftMenu()
        }
    }
}
