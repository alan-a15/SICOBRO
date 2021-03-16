//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class AppVersion: Codable {
    enum CodingKeys: String, CodingKey {
        case version = "Version"
        case so = "So"
    }
    
    var version: String = ""
    let so: Int = 2
}
