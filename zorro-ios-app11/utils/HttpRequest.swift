//
//  File.swift
//  zorro-ios-app11
//
//  Created by Héctor Enrique Díaz Hernández on 10/12/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import Alamofire

class HttpRequest {
    static let INCOMPLETE = -1
    
    private static let BASE_URL = "http://170.245.189.244/kioscoapi/api"
    private static let KEY = "1cWi6-FNd3YX7Z6[2-YGnsERewLpt:8Sj:ITtEE6UeUfG?x8y"
    private static let GET_HEADERS: HTTPHeaders = [
        .accept("application/json"),
        HTTPHeader(name: "Key", value: KEY)
    ]
    private static let POST_HEADERS: HTTPHeaders = [
        .accept("application/json"),
        .contentType("application/json"),
        HTTPHeader(name: "Key", value: KEY)
    ]
    
    private static func createUrl(_ url: String) -> String {
        return "\(HttpRequest.BASE_URL)/\(url)"
    }
    
    private static func processRequest(_ request: DataRequest,
                                       success: @escaping (String) -> Void,
                                       failure: @escaping (Int, String) -> Void,
                                       always: (() -> Void)?) {
        request.validate(statusCode: 200..<300).responseString { response in
            always?()
            
            print("HTTP Request: \(response.request?.url?.absoluteString ?? "URL")")
            // EL HECTOR ESTUVO AQUÍ 05/02/2021
            switch response.result {
            
            case let .success(content):
                print("Success: \(content)")
                success(content)
                
                break
            case let .failure(error):
                var content = "Request incomplete"
                var code = INCOMPLETE
                
                guard error.underlyingError != nil else {
                    code = error.responseCode!
                    content = String(bytes: response.data!, encoding: .utf8)!
                    print("Failure. \(code): \(content)")
                    
                    failure(code, content)
                    
                    break
                }
                
                print("Failure. \(code): \(content)")
                failure(code, content)
                
                break
            }
        }
    }
    
    static func httpGet(_ url: String,
                        success: @escaping (String) -> Void,
                        failure: @escaping (Int, String) -> Void,
                        always: (() -> Void)? = nil) {
        processRequest(AF.request(createUrl(url),
                                  headers: HttpRequest.GET_HEADERS) { (urlRequest: inout URLRequest) in
            urlRequest.timeoutInterval = 15
        },
        success: success,
        failure: failure,
        always: always)
    }
    
    static func httpPost(_ url: String,
                         body: String,
                         success: @escaping (String) -> Void,
                         failure: @escaping (Int, String) -> Void,
                         always: (() -> Void)? = nil) {
        processRequest(AF.request(createUrl(url),
                                  method: .post,
                                  parameters: body,
                                  encoder: JSONParameterEncoder.default,
                                  headers: HttpRequest.POST_HEADERS) { (urlRequest: inout URLRequest) in
            urlRequest.timeoutInterval = 15
        },
        success: success,
        failure: failure,
        always: always)
    }
    
    static func httpPost<T>(_ url: String,
                            body: T,
                            success: @escaping (String) -> Void,
                            failure: @escaping (Int, String) -> Void,
                            always: (() -> Void)? = nil) where T : Codable {
        processRequest(AF.request(createUrl(url),
                                  method: .post,
                                  parameters: body,
                                  encoder: JSONParameterEncoder.default,
                                  headers: HttpRequest.POST_HEADERS) { (urlRequest: inout URLRequest) in
            urlRequest.timeoutInterval = 15
        },
        success: success,
        failure: failure,
        always: always)
    }
}
