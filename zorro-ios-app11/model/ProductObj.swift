//
//  ProductObj.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 19/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import SwiftyJSON

class ProductObj : ProductDto {

    var lstFixedAmount : [Int] = []

    func prepareFixedAmount() {
        if let fixedAmountsEnabled = fixedAmountsEnabled,
           let fixedAmounts = fixedAmounts,
           fixedAmountsEnabled && !fixedAmounts.isEmpty  {
            
           debugPrint("fixedAmounts: [\(fixedAmounts)]")
           if let dataFromString = fixedAmounts.data(using: String.Encoding.utf8, allowLossyConversion: false) {
                do {
                    let json = try JSON(data: dataFromString).array
                    json?.forEach({ (item) in
                        debugPrint("item: [\(item)]")
                        var value = item.int ?? 0
                        debugPrint("item: [\(value)]")
                        lstFixedAmount.append( value )
                    })
                } catch {
                    print("Error \(error)")
                }
            }
        }
    }

    static func fromProduct(sproduct : ProductDto?) -> ProductObj {
        var productObj =  ProductObj()
        if let product = sproduct {
            productObj.name = product.name
            productObj.fixedAmounts = product.fixedAmounts
            productObj.fixedAmountsEnabled = product.fixedAmountsEnabled
            productObj.referenceDescription = product.referenceDescription
            productObj.referenceSizeDescription = product.referenceSizeDescription
            productObj.segmentId = product.segmentId
            productObj.status = product.status
            productObj.txnId = product.txnId
            productObj.referenceImage = product.referenceImage
            productObj.customerCommission = product.customerCommission
            productObj.ownerCommission = product.ownerCommission
            productObj.providerCommission = product.providerCommission
            productObj.prepareFixedAmount()
        }
        return productObj
    }
}
