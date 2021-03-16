//
//  Banner.swift
//  zorro-ios-app1
//
//  Created by José Antonio Hijar on 3/16/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit

/// Enum
enum BannerTarget : String {
    case CARROUSEL = "CARROUSEL"
    case AD = "AD"
    case COMINUDADRED = "COMUNIDADRED"
    case FINDSTORE = "FINDSTORE"
    case VOLANTES = "VOLANTES"
    case SICOBRO = "SICOBRO"
    case URL = "URL"
}

/// Banner
struct Banner : Identifiable {
    var id: String = UUID().uuidString
    
    let name:String
    var description:String
    var enabled:Bool
    var imageSrc:String
    var target:BannerTarget
    var targetUrl:String
    var carruselImages : [Banner]?
    
    init(name : String, description:String, enabled:Bool, imageSrc:String, target: BannerTarget, targetUrl:String) {
        self.name = name
        self.description = description
        self.enabled = enabled
        self.imageSrc = imageSrc
        self.target = target
        self.targetUrl = targetUrl
        self.carruselImages = nil
    }
    
    init(_ dic: [String: Any]) {
        self.name = dic["name"] as? String ?? ""
        self.description = dic["description"] as? String ?? ""
        self.enabled = dic["enabled"] as? Bool ?? false
        self.imageSrc = dic["imageSrc"] as? String ?? ""
        self.target = BannerTarget(rawValue: dic["target"] as? String ?? "")!
        self.targetUrl = dic["targetUrl"] as? String ?? ""
        
        let images = dic["carruselImages"] as? [[String: Any]] ?? nil
        if(images != nil) {
            self.carruselImages = [Banner]()
            for idic in images! {
                self.carruselImages?.append(Banner(idic))
            }
        } else {
            self.carruselImages = nil
        }
    }
}
