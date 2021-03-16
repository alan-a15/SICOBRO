//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class Promocion: Codable {
    enum CodingKeys: String, CodingKey {
        case nombre = "Nombre"
        case ofertas = "Ofertas"
    }
    
    var nombre: String = ""
    var ofertas: [Oferta] = [Oferta]()
}
