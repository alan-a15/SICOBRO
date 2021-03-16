//
//  ContactUsItem.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 01/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

struct ContactUsItem : Identifiable {
    var id: String
    let label:String
    var value:String
    var imageSrc:String

    init(id : String, label:String, value:String, imageSrc:String) {
        self.id = id
        self.label = label
        self.value = value
        self.imageSrc = imageSrc
    }
    
    init(_ dic: [String: Any]) {
        self.id = dic["id"] as? String ?? ""
        self.label = dic["label"] as? String ?? ""
        self.value = dic["value"] as? String ?? ""
        self.imageSrc = dic["imageSrc"] as? String ?? ""
    }
}
