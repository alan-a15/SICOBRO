//
//  zorro_ios_app11Tests.swift
//  zorro-ios-app11Tests
//
//  Created by José Antonio Hijar on 21/03/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import XCTest
import zorro_ios_app11
import Alamofire
@testable import zorro_ios_app11

class zorro_ios_app11Tests: XCTestCase {

    var authenticationService : AuthenticationService!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        authenticationService = AuthenticationService()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testLogin1() {
        let request : LoginRequest = LoginRequest()
        request.redId = "001426018"
        request.storePassword = "F267"
        request.storeUsername = "100022"
        
        // TO-DO: Get object with devide informaiton
        request.deviceId = "11111"
        request.deviceBrand = "Apple"
        request.deviceModel = "Iphone Test 8"
        request.deviceOSVersion = "11.0"
        
        authenticationService.performCredentialLogin(loginReq: request, callback: createLoginCallback())
    }
    
    private func createLoginCallback() -> RestCallback<LoginResponse> {
        let loginOnResponse : ((LoginResponse?) -> ())? = { response in
            print("response \(String(describing: response))")
            print("actionRequired \(String(describing: response?.actionRequired))")
            print("maskedEmail \(String(describing: response?.maskedEmail))")
            print("sessionToken \(String(describing: response?.sessionToken))")
        }
        
        let loginApiError : ((ApiError)->())? =  { apiError in
            print("Login Error: \(String(describing: apiError.message))")
        }
        
        let loginOnFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
        }
        return RestCallback<LoginResponse>(onResponse: loginOnResponse, onApiError: loginApiError, onFailure: loginOnFailure)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
