//
//  DeviceUtil.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import UIKit
import DeviceKit

public class DeviceUtil {
    
    static var deviceInfo : DeviceInfo?
    
    /*
     * Get related device Info.
     * TO-DO: Store this info tin the properties as well.
     */
    static func getDeviceInfo() -> DeviceInfo {
        if self.deviceInfo != nil {
            return self.deviceInfo!
        }
        let device = Device.current
        deviceInfo = DeviceInfo()
        deviceInfo?.deviceId = getDeviceIdentifier()
        deviceInfo?.deviceModel = device.description
        deviceInfo?.deviceBrand = device.model ??  "--"
        deviceInfo?.deviceOSVersion = (device.systemName ?? "iOS") + " " + (device.systemVersion ?? "--")
        deviceInfo?.deviceVersionRelease = (device.systemName ?? "iOS") + " " + (device.systemVersion ?? "--")
        return deviceInfo!
    }
    
    /*
     * Try to retrieve unique device identifier. First there is an attempt to get Vendor identifier. If Vendor identifier is not available, look for a andom UUID identifier.
     * This daa is expected to be stored in KeyChain. First it is required to verify the data exists in KeyChain, otherwise we will generate it
     */
    private static func getDeviceIdentifier() -> String {
        guard let identifier = UIDevice.current.identifierForVendor else {
            let uuid = UUID().uuidString
            print("Random Device Identifier \(uuid)")
            return uuid
        }
        let ifv:String = identifier.uuidString
        print("Identifier for Vendor: \(ifv)")
        return ifv
    }
}
