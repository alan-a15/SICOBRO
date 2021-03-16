//
//  NotificationsManager.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 07/01/21.
//  Copyright © 2021 José Antonio Hijar. All rights reserved.
//

import Foundation
import UIKit

class NotificationsManager {
    static let key = "notifications"
    
    static func setNotificationsBadge(_ notifications: Int) {
        UIApplication.shared.applicationIconBadgeNumber = notifications > 0 ? notifications : 0
    }
    
    static func setNotificationsTo(_ count: Int) {
        let defaults = UserDefaults.init(suiteName: RedDefaults.comunidadRed.rawValue)!
        
        defaults.setValue(count, forKey: key)
        
        setNotificationsBadge(count)
    }
    
    static func addNotifications(_ notifications: Int) {
        let defaults = UserDefaults.init(suiteName: RedDefaults.comunidadRed.rawValue)!
        let count = defaults.integer(forKey: key) + notifications
        
        defaults.setValue(count, forKey: key)
        
        setNotificationsBadge(count)
    }
}
