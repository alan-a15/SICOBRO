//
//  SessionManagement.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 05/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class SessionManager {
    
    let APP_ID = "zorroIOS"
    
    enum Key: String, CaseIterable {
        case USERINFO
        
        case USERNAME
        case STORE_ID, RED_ID
        case PASSWORD,PASSWORD_PLAIN
        case STOREUSERNAME
        case STORENAME
        case PHONE
        case IS_ACTIVATED
        case REQUIRED_RESET_PWD
        case SESSION_TIMEOUT
        case CREDENTIALS_LAST_LOGIN
        case CREDENTIALS_FIRST_LOGIN
        case LAST_LOGIN
        case LAST_LOGGED_USER_INTERACTION
        case IS_NEW_SICOBROUSER
        case BPCK_TOKEN
        
        func make(for appId: String) -> String {
            return self.rawValue + "_" + appId
        }
    }
    
    let sessionInfo: UserDefaults
    var loadedUser:UserInfoLoginResponse?
    
    private static var singleton:SessionManager?
    
    static func getInstance() -> SessionManager {
        guard singleton != nil else {
            singleton = SessionManager()
            return singleton!
        }
        return singleton!
    }
    
    init(sessionInfo: UserDefaults = .standard) {
        self.sessionInfo = sessionInfo
    }

    /*
    func getUserInfo(forUserID userID: String) -> (name: String?, avatarData: Data?) {
        let name: String? = readValue(forKey: .name, userID: userID)
        let avatarData: Data? = readValue(forKey: .avatarData, userID: userID)
        return (name, avatarData)
    }
  */
    
    /*
     *
     */
    func createInitialUserSession(user:UserInfoLoginResponse, initialLogin : Bool = true) {
        self.loadedUser = nil
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            storeProp(forKey: Key.USERINFO, value: encoded)
        }
        
        let dateSecs : TimeInterval = Date().timeIntervalSince1970
        if (initialLogin) {
            storeProp(forKey: Key.CREDENTIALS_LAST_LOGIN, value: dateSecs)
        }
        storeProp(forKey: Key.LAST_LOGIN, value: dateSecs)
        storeProp(forKey: Key.LAST_LOGGED_USER_INTERACTION, value: dateSecs)
        storeProp(forKey: Key.IS_NEW_SICOBROUSER, value: user.pwdEmailed)
        
        setFirstLoginUser()
    }
    
    /*
     *
     */
    func loadUserSession(forceReload:Bool = false) -> UserInfoLoginResponse? {
        if(forceReload) {
            self.loadedUser = nil
        }
        
        guard self.loadedUser != nil else {
            if let userSession:Data = getProp(forKey: Key.USERINFO) {
                let decoder = JSONDecoder()
                if let loadedUser = try? decoder.decode(UserInfoLoginResponse.self, from: userSession) {
                    self.loadedUser = loadedUser
                    return loadedUser
                }
            }
            return nil
        }
        return self.loadedUser
    }
    
    /*
     *
     */
    func saveSessionData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(self.loadedUser) {
            storeProp(forKey: Key.USERINFO, value: encoded)
        }
    }
    
    /**
     * Validate if user has logged at least once
     */
    func isUserHadFirstLogin() -> Bool {
        let firstCredsLogin:TimeInterval? = getProp(forKey: Key.CREDENTIALS_FIRST_LOGIN)
        print("isUserHadFirstLogin \(firstCredsLogin)")
        guard firstCredsLogin != nil else {
            return false
        }
        return true
    }
    /**
     *
     */
    func setFirstLoginUser() {
        if(!isUserHadFirstLogin()) {
            let dateSecs : TimeInterval = Date().timeIntervalSince1970
            storeProp(forKey: Key.CREDENTIALS_FIRST_LOGIN, value: dateSecs)
        }
    }
    
    /*
     *
     */
    func isUserLoggedIn() -> Bool {
        let data:Data? = getProp(forKey: Key.USERINFO)
        print("isUserLoggedIn \(data)")
        let user:UserInfoLoginResponse? = loadUserSession(forceReload: true)
        print("isUserLoggedIn \(user)")
        guard user != nil else {
            return false
        }
        return true
    }
    
    /*
     *
     */
    func isUserActivated() -> Bool {
        let user:UserInfoLoginResponse? = loadUserSession(forceReload: true)
        return user?.active ?? false
    }
    
    /*
     *
     */
    func isChangePasswordRequired() -> Bool {
        let user:UserInfoLoginResponse? = loadUserSession()
        return user?.requireResetPwd ?? false
    }
    
    /*
     *
     */
    func isUserLoggedInWithPin()  -> Bool {
        let data:TimeInterval? = getProp(forKey: Key.LAST_LOGIN)
        print("isUserLoggedInWithPin \(data)")
        guard data != nil else {
            return false
        }
        return true
    }
    
    /*
     *
     */
    func getStoredSessionToken() -> String {
        let user:UserInfoLoginResponse? = loadUserSession()
        return user?.sessionToken ?? ""
    }
    
    /*
     *
     */
    func setTimeoutSession(timeoutInSeconds:Int = 300) {
        storeProp(forKey: Key.SESSION_TIMEOUT, value: timeoutInSeconds)
    }
    
    /*
     *
     */
    func setUserProperty(key: Key, value: Any) {
        loadedUser = loadUserSession()
        switch key {
            case .REQUIRED_RESET_PWD:
                loadedUser?.requireResetPwd = (value as! Bool)
                break;
            case .BPCK_TOKEN:
                loadedUser?.billpocketToken = (value as! String)
                break;
            default:
                print("Unsupported property")
        }
        saveSessionData()
    }
    
    /*
     *
     */
    func validateLastLoginCredentials() -> Bool {
        if let lastCredsLogin : TimeInterval = getProp(forKey: Key.CREDENTIALS_LAST_LOGIN) {
            
            let timezoneOffset =  TimeZone.current.secondsFromGMT()
            var lastCredsLoginTime = Date(timeIntervalSince1970: lastCredsLogin)
            lastCredsLoginTime = lastCredsLoginTime.addingTimeInterval(Double(timezoneOffset))
            
            var currentTime = Date()
            currentTime = currentTime.addingTimeInterval(Double(timezoneOffset))
    
            // For dev purposes
            //currentTime = currentTime.addingTimeInterval( 60*60*24 )
            
            print("CREDENTIALS_LAST_LOGIN time: \(lastCredsLoginTime)")
            print("Current time: \(currentTime)")
            
            let calender:Calendar = Calendar.current
            let components: DateComponents = calender.dateComponents([.day, .hour, .minute, .second], from: lastCredsLoginTime, to: currentTime)

            // For dev purposes
            //if (components.minute! >= 1) {
            if (components.day! >= 1) {
                print("Login Expired")
                invalidatePreferences()
                return false
            } else {
                
                let startDate = calender.ordinality(of: .day, in: .era, for: lastCredsLoginTime)
                let endDate = calender.ordinality(of: .day, in: .era, for: currentTime)
                
                print("calender \(calender)")
                print("startDate \(String(describing: startDate))")
                print("endDate \(String(describing: endDate))")
                
                //let isDateToday = calender.isDateInToday(lastCredsLoginTime)
                //print("isDateToday \(isDateToday)")
                if(startDate != endDate) {
                        print("Login Expired")
                        invalidatePreferences()
                        return false
                }
            }
            print("Login Session Still valid")
            return true
        }
        print("Login session property doesn't exist yet")
        return false
    }
    
    /*
     *
     */
    func validateActiveSession() -> Bool {
        return true     // Always true for now, as we expect the session to be closed at the end of the day and that is covered.
    }
    
    /*
     *
     */
    func closeSession() -> Bool  {
        removeProp(forKey: Key.LAST_LOGIN)
        removeProp(forKey: Key.LAST_LOGGED_USER_INTERACTION)
        removeProp(forKey: Key.SESSION_TIMEOUT)
        return true
    }
    
    /*
     *
     */
    func invalidatePreferences(clearAll:Bool = false) {
        Key
            .allCases
            .filter({ (key) -> Bool in
                key != .CREDENTIALS_FIRST_LOGIN || clearAll
                // Preserve CREDENTIALS_FIRST_LOGIN in session.
            })
            .map { $0.make(for: APP_ID) }
            .forEach { key in
                sessionInfo.removeObject(forKey: key)
        }
        
        
    }
    
    /*
     *
     */
    func storeProp(forKey key: Key, value: Any) {
        sessionInfo.set(value, forKey: key.make(for: APP_ID))
    }
    
    /*
     *
     */
    func removeProp(forKey key: Key) {
        sessionInfo.removeObject(forKey: key.make(for: APP_ID))
    }
    
    /*
     *
     */
    func getProp<T>(forKey key: Key) -> T? {
        return sessionInfo.value(forKey: key.make(for: APP_ID)) as? T
    }
    
    
}
