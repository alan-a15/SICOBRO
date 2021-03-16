//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class Sucursal: Codable {
    enum CodingKeys: String, CodingKey {
        case sucursal = "Sucursal"
        case nombre = "Nombre"
    }
    
    var sucursal: String = ""
    var nombre: String = ""
}
