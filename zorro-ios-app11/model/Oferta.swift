//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class Oferta: Codable {
    enum CodingKeys: String, CodingKey {
        case articulo = "Articulo"
        case descuento = "Descuento"
        case leyenda = "Leyenda"
        case vigencia = "Vigencia"
    }
    
    var articulo: String = ""
    var descuento: String = ""
    var leyenda: String? = ""
    var vigencia: String? = ""
}
