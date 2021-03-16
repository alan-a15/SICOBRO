//
//  ZorroAbstracUIViewController.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 03/01/21.
//  Copyright © 2021 José Antonio Hijar. All rights reserved.
//

import Foundation
import UIKit
import MaterialComponents.MaterialNavigationDrawer

enum RedDefaults : String {
    case comunidadRed = "COM_RED"
    case firebase = "COM_FIREBASE"
}

class ZorroAbstracUIViewController: AbstractUIViewController {
    let version: String
    let noRed: String
    
    let defaults = UserDefaults.init(suiteName: RedDefaults.comunidadRed.rawValue)!
    
    var bottomNavigationDrawer: MDCBottomDrawerViewController? = nil
    
    required init?(coder: NSCoder) {
        self.noRed = defaults.string(forKey: "noRed") ?? ""
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.version = version
        } else {
            self.version = ""
        }
        
        super.init(coder: coder)
    }
    
    @objc func back() {
        print("back")
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func showMenu() {
        present(bottomNavigationDrawer!, animated: true, completion: nil)
    }
    
    func addBackButton(_ image: UIImageView) {
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(back))
        image.addGestureRecognizer(tap1)
        image.isUserInteractionEnabled = true
    }
    
    func addBottomNavigationDrawer(_ image: UIImageView) {
        bottomNavigationDrawer = MDCBottomDrawerViewController()
        let viewContent = storyboard?.instantiateViewController(withIdentifier: "navigationDrawer") as! NavigationDrawerViewController
        viewContent.handler = self.performTransitionWithIdentifier(identifier:destroyCurrentView:)
        //        bottomDrawerViewController.headerViewController = UIViewController() # this is optional
        
        bottomNavigationDrawer!.contentViewController = viewContent
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        image.addGestureRecognizer(tap1)
        image.isUserInteractionEnabled = true
    }
}
