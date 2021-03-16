//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class Volante: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case titulo = "Titulo"
        case vigenciaStr = "VigenciaStr"
        case imagenes = "Imagenes"
    }
    
    var id: Int = 0
    var titulo: String = ""
    var vigenciaStr: String = ""
    var imagenes: [String] = [String]()
}
