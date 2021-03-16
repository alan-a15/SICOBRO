//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class Geolocalizacion: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case nombre = "Nombre"
        case latitud = "Latitud"
        case longitud = "Longitud"
    }
    
    var id: Int = 0
    var nombre: String = ""
    var latitud: Double = 0.0
    var longitud: Double = 0.0
}
