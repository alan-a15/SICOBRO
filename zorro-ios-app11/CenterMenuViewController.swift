//
//  CenterMenuViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 22/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class CenterMenuViewController: AbstractUIViewController {
        
    var menuHandler : MenuHandler?
    
    var bottomController : BottomViewController?
    
    var delegate: CenterMenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // Specific class should have an  IBAction method invoking this
    @objc func openLeftMenu() {
        print("On openLeftMenu")
        delegate?.toggleLeftPanel()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.destination {
            case let bottomController as BottomViewController:
                bottomController.parentController = self
                self.bottomController = bottomController
            
            default:
                break
        }
    }
    
    
}

extension CenterMenuViewController: LeftMenuViewControllerDelegate {
  func collapse() {
    delegate?.collapseSidePanels()
  }
}

protocol MenuHandler {
    func getMenuType() -> MenuItemSection
}

protocol CenterMenuViewControllerDelegate {
  func toggleLeftPanel()
  
  func collapseSidePanels()
}
