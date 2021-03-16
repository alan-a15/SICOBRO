//
//  SideMenuItem.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 22/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

/// Enum
enum MenuItemSection : String {
    case BANNERS = "BANNERS"
    case SICOBRO = "SICOBRO"
}

/// Banner
struct SideMenuItem : Identifiable {
    var id: String
    let label:String
    var imageSrc:String
    var showsIn : [MenuItemSection?] = []
    
    var type:String
    var url:String?
    
    init(id : String, label:String, imageSrc:String, type:String, showsIn: [MenuItemSection]) {
        self.id = id
        self.label = label
        self.imageSrc = imageSrc
        self.showsIn = showsIn
        self.type = type
    }
    
    init(_ dic: [String: Any]) {
        self.id = dic["id"] as? String ?? ""
        self.label = dic["label"] as? String ?? ""
        self.imageSrc = dic["imageSrc"] as? String ?? ""
        self.type = dic["type"] as? String ?? ""
        self.url = dic["URL"] as? String ?? ""
        let sections = dic["showsIn"] as? [String] ?? nil
        if(sections != nil) {
            self.showsIn = [MenuItemSection]()
            for section in sections! {
                self.showsIn.append(MenuItemSection(rawValue: section))
            }
        }
    }
}
