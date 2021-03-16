//
//  UrlsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/07/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

class FaqViewController: ZorroAbstracUIViewController {
    
    var comunicado: Comunicado = Comunicado()
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var menuButton: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBackButton(backButton)
        addBottomNavigationDrawer(menuButton)
    }
}
