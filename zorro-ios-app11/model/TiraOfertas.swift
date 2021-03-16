//
//  Volante.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 21/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class TiraOfertas: Codable {
    enum CodingKeys: String, CodingKey {
        case numeroCliente = "NumeroCliente"
        case sucursal = "Sucursal"
        case fechaImpresion = "FechaImpresion"
        case nombreSocio = "NombreSocio"
        case leyendaEncabezado = "LeyendaEncabezado"
        case numeroClienteFrecuente = "NumeroClienteFrecuente"
        case notaPieTira01 = "NotaPieTira01"
        case notaPieTira02 = "NotaPieTira02"
        case promociones = "Promociones"
    }
    
    var numeroCliente: String = ""
    var sucursal: Sucursal = Sucursal()
    var fechaImpresion: String = ""
    var nombreSocio: String = ""
    var leyendaEncabezado: String? = ""
    var numeroClienteFrecuente: String = ""
    var notaPieTira01: String = ""
    var notaPieTira02: String = ""
    var promociones: [Promocion] = [Promocion]()
}
