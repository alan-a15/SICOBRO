//
//  UserInfo.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 06/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation

class UserInfoLoginResponse : Codable {
    
    var user : String? = ""
    var redId : String? = ""
    var storeId : String? = ""
    var password : String? = ""
    var storeUsername:String? = ""
    //var passwordBytes : byte
    var phone : String = ""
    var email : String = ""
    var maskedEmail : String? = ""

    var secretPin : String = ""

    // LoginResponse information
    var active : Bool = false   // Based on actionRequired Field
    var requireResetPwd : Bool = false   // Based on actionRequired Field
    var pwdEmailed : Bool = false   // Based on actionRequired Bool
    var sessionToken :String? = ""
    var storeName : String? = "" // TO-DO: Remove this default value
    var billpocketToken : String? = ""
    var billpocketDeviceToken : String? = ""
    var billpocketModuleEnabled : Bool = false
    var taeModuleEnabled : Bool = false
    var servicePaymentModuleEnabled : Bool = false
    var actionRequired : LoginResponse.ActionRequired?

    var lastLogin : Date? = nil
    var lastPinLogin : Date? = nil
    var lastUserInteraction : Date? = nil
    var avatarURL : String = ""
    
    func addDataFromLoginResponse(loginData : LoginResponse) {
        user = loginData.user
        storeUsername = loginData.storeId
        storeId = loginData.storeId
        storeName = loginData.storeName
        sessionToken = loginData.sessionToken
        billpocketToken = loginData.billpocketToken
        billpocketModuleEnabled = loginData.billpocketModuleEnabled ?? false
        taeModuleEnabled = loginData.taeModuleEnabled ?? false
        servicePaymentModuleEnabled = loginData.servicePaymentModuleEnabled ?? false
        actionRequired = loginData.actionRequired
        maskedEmail = loginData.maskedEmail

        active = //actionRequired != LoginResponse.ActionRequiredEnum.ACTIVATE_AND_CHANGE_PASSWORD &&
                 //actionRequired != LoginResponse.ActionRequiredEnum.ACTIVATE_FIRST_LOGIN &&
                 actionRequired != LoginResponse.ActionRequired.usePasswordEmailed

        requireResetPwd = actionRequired == LoginResponse.ActionRequired.changePassword
                          //  ||
                          //actionRequired == LoginResponse.ActionRequiredEnum.ACTIVATE_AND_CHANGE_PASSWORD

        pwdEmailed = actionRequired == LoginResponse.ActionRequired.usePasswordEmailed
    }
    
}
