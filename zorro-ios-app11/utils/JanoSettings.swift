//
//  JanoSettings.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class JanoSettings : Decodable {
    var host:String = ""
    var timeout:Int = 0
    var appversion:String = ""
    var isDev = false
    var readTimeout:Int = 0
    var simulateLatency = false

    var paymentServicesHost = ""
    var paymentServicesTimeout:Int = 0
    var paymentServicesReadTimeout:Int = 0
    
    private static var singleton:JanoSettings?
    
    static func getSettingsInstance() -> JanoSettings {
        guard let ssingleton = singleton else {
            do {
                singleton = try JanoSettings.fromJsonPath()!
            } catch let error {
                print("Error trying to parse settings: \(error)")
                singleton = JanoSettings()
            }
            return singleton!
        }
        return singleton!
    }

    func getVisibleVersion() -> String {
        if( appversion.isEmpty ) {
            return "-.-.-"
        }
        let index = appversion.firstIndex(of: "-") ?? appversion.endIndex
        let visibleVersion = appversion[..<index]
        return String(visibleVersion)
    }
    
    static func fromJsonPath() throws -> JanoSettings?  {
        let fileName = Environment.isDev() ? "jano_dev" : "jano_prod"
        let settings:JanoSettings? = JsonUtils.jsonToObject(fileName: fileName, type: JanoSettings.self)
        debugPrint("JSON Settings loaded: ")
        debugPrint("isDev: \(settings?.isDev)")
        debugPrint("appversion: \(settings?.appversion)")
        debugPrint("host: \(settings?.host)")
        debugPrint("timeout: \(settings?.timeout)")
        debugPrint("readTimeout: \(settings?.readTimeout)")
        debugPrint("paymentServicesHost: \(settings?.paymentServicesHost)")
        debugPrint("paymentServicesTimeout: \(settings?.paymentServicesTimeout)")
        debugPrint("paymentServicesReadTimeout: \(settings?.paymentServicesReadTimeout)")
        return settings
    }
}
