//
//  Utils.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 09/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class Utils {

    static let sdateFormat = "dd 'de' LLLL 'del' YYYY"
    static let MODEL_DATE_FORMAT = "dd/MM/yyyy HH:mm:ss"

    static func getParsedDateForHeader(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.locale = Locale(identifier: "es_MX")
        dateFormatterPrint.dateFormat = sdateFormat
        return dateFormatterPrint.string(from: date)
    }
    
    static func formatCurrency(number: Double) -> String {
        let currencyFormatter = NumberFormatter()
        currencyFormatter.usesGroupingSeparator = true
        currencyFormatter.currencySymbol = "$"
        currencyFormatter.numberStyle = .currencyAccounting
        //currencyFormatter.locale = Locale.current
        
        return currencyFormatter.string(from: NSNumber(value: number)) ?? "-.--"
    }
    
    
    static func formatDecimal(number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        //formatter.decimalSeparator = "."
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        //currencyFormatter.locale = Locale.current
        
        return formatter.string(from: NSNumber(value: number)) ?? "0.00"
    }
    
    static func format(date: Date, withFormatString: String) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = withFormatString
        return dateFormatterPrint.string(from: date)
    }
    
    static func generateRandomIdentifier() -> String {
        let uid = UUID.init().uuidString.replacingOccurrences(of: "-", with: "")
        
        var finalUid = ""
        for _ in 1...12 {
            let randomn = Int.random(in: 0...(uid.count - 1))
            let index = uid.index(uid.startIndex, offsetBy: randomn)
            finalUid += "\(uid[index])"
        }
        
        return finalUid
    }
    
    static func prepareStringForURLParam(value:String) -> String {
        var vv = value.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        vv = vv.replacingOccurrences(of: "&", with: "%26")
        return vv
    }

}
