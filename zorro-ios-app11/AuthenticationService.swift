//
//  AuthenticationService.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 10/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Alamofire
import Foundation

public class AuthenticationService : AbstractRestService {
    private let LG_LOGIN_BACKWARD_COMPATIBLE_ENDPOINT:String = "/login-backwardcompatible"
    private let LG_CHANGE_PASSWORD_ENDPOINT:String = "/change-password"
    private let MSC_SESSION_TIMEOUT_ENDPOINT:String = "/session-timeout-in-seconds"
    private let LG_REQUEST_CHANGE_PASSWORD_ENDPOINT:String = "/request-change-password"
    
    // Not used anymore
    private let LG_REQUEST_ACTIVATION_CODE:String = "/requestActivationCode"
    private let LG_ACTIVATE_DEVICE_ENDPOINT:String = "/activateDevice"
    
    private static var singleton:AuthenticationService?
    
    static func getInstance() -> AuthenticationService {
        guard singleton != nil else {
            singleton = AuthenticationService()
            return singleton!
        }
        return singleton!
    }
    
    /**
     *
     */
    func performCredentialLogin(loginReq : LoginRequest, callback: RestCallback<LoginResponse>) {
        let endpointURL = getEndpointUrl(path: LG_LOGIN_BACKWARD_COMPATIBLE_ENDPOINT)
        var processor = RestServiceProcessor<LoginRequest, LoginResponse>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER])
        processor.invoke(request: loginReq, callback: callback)
    }
    
    /**
     *
     * DEPRECATED
     */
    func requestActivationCode(phoneNumber : String, callback: RestCallback<Void>) {
        print("NOT IMPLEMENTED, DEPRECATED")
    }
    
    /**
     * DEPRECATED  as all user should be activated now
     * Asynchronous version of activateDeviceWithCode. The callback definition should come from Activity.
     */
    func activateDeviceWithCode(activationCode: String, callback: RestCallback<Void>) {
        print("NOT IMPLEMENTED, DEPRECATED")
    }
    
    /**
     * Retrieve session timeout from JANO Backend
     */
    func getSessionTimeout(callback: RestCallback<Int>) {
        let endpointURL = getEndpointUrl(path: MSC_SESSION_TIMEOUT_ENDPOINT)
        let processor = RestServiceProcessor<String?, Int>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                           AbstractRestService.DEVICEID_HEADER,
                                                           AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
    /**
     * Set new password for specified user
     */
    func changePassword(request:ChangePasswordRequest, callback: RestCallback<String>) {
        let endpointURL = getEndpointUrl(path: LG_CHANGE_PASSWORD_ENDPOINT)
        let processor = RestServiceProcessor<ChangePasswordRequest, String>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                           AbstractRestService.DEVICEID_HEADER,
                                                           AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(request: request, callback: callback)
    }
    
    /**
     *
     *
     */
    func requestChangePassword(request:InitiatePasswordChangeRequest, callback: RestCallback<String>) {
        let endpointURL = getEndpointUrl(path: LG_REQUEST_CHANGE_PASSWORD_ENDPOINT)
        let processor = RestServiceProcessor<InitiatePasswordChangeRequest, String>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER])
        processor.invoke(request: request, callback: callback)
    }
    
}
