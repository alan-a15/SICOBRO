//
//  Environment.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 13/06/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

struct Environment {

    private static let debug : Bool = {
        #if DEBUG
            print("DEBUG")
            return true
        #else
            print("RELEASE")
            return false
        #endif
    }()

    private static let dev : Bool = {
        #if DEV
            print("DEV")
            return true
        #else
            print("PROD")
            return false
        #endif
    }()
    
    static func isDebug () -> Bool {
        return self.debug
    }
    
    static func isDev () -> Bool {
        return self.dev
    }
}
