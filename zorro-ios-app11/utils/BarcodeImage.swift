//
//  BarcodeImage.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 11/01/21.
//  Copyright © 2021 José Antonio Hijar. All rights reserved.
//

import Foundation
import UIKit
import CoreImage

extension UIImage {
    
    convenience init?(barcode: String, size: CGSize) {
        let data = barcode.data(using: .ascii)
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        guard let image = filter.outputImage else {
            return nil
        }
        
        let imageSize = image.extent.size

        let scaledImage = image.transformed(by: CGAffineTransform(scaleX: size.width / imageSize.width, y: size.height / imageSize.height))
        
        self.init(ciImage: scaledImage)
    }
    
}
