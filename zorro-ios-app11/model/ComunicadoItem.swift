//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class ComunicadoItem: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case idCampana = "IdCampana"
        case titulo = "Titulo"
        case notificacion = "Notificacion"
        case visto = "Visto"
        case imagen = "Imagen"
    }
    
    var id: Int = 0
    var idCampana: Int = 0
    var titulo: String = ""
    var notificacion: String = ""
    var visto: Bool = false
    var imagen: String? = ""
}
