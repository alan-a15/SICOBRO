//
//  AbstractRestService.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 11/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Alamofire
import Foundation

/**
 *
 */
public class AbstractRestService {
    
    static let APPVERSION_HEADER:String = "appversion"
    static let DEVICEID_HEADER:String = "deviceId"
    static let SESSIONTOKEN_HEADER:String = "sessionToken"
    
    /*
     * These 3 objects should be singletons
     */
    let sessionManager : SessionManager
    let settings : JanoSettings
    let deviceInfo : DeviceInfo
    
    init() {
        deviceInfo = DeviceUtil.getDeviceInfo()
        sessionManager = SessionManager.getInstance()
        settings = JanoSettings.getSettingsInstance()
    }
    
    let REST_API_BASE_PATH = "/api/sales"
    let REST_PAYMENT_SERVICES_API_BASE_PATH = "/api/servicepayment"
        
    /*
     * Build the endpoint URL using the server host from Settings and the REST BASE Path as suffix.
     * @param path: Rest endpoint path
     */
    func getEndpointUrl(path : String, isPaymentServices:Bool = false) -> String {
        return (isPaymentServices ? (settings.paymentServicesHost + REST_PAYMENT_SERVICES_API_BASE_PATH) : (settings.host + REST_API_BASE_PATH)) + path
    }
    
    /*
     * Adding default Jano headers to the processor's headers. This method will honor default header values like:
     *    APPVERSION_HEADER
     *    DEVICEID_HEADER
     *    SESSIONTOKEN_HEADER
     * @processor: Processor that build the request with headers
     * @headerNames: Array of headers to be added to processor's request.
     */
    func addJanoHeaders<T:Encodable,R:Decodable>(processor: RestServiceProcessor<T,R>, headerNames : [String]) {
        headerNames.forEach { (header) in
            switch(header) {
                case AbstractRestService.APPVERSION_HEADER:
                    processor.addHeader(name: header, value: settings.appversion)
                    break
                
                case AbstractRestService.DEVICEID_HEADER:
                    processor.addHeader(name: header, value: deviceInfo.deviceId)
                    break
                
                case AbstractRestService.SESSIONTOKEN_HEADER:
                    processor.addHeader(name: header, value: sessionManager.getStoredSessionToken())
                    break
                default:
                    print("Ignoring heder [\(header)]")
            }
        }
    }
}

/**
 *
 */
class RestCallback<T>{
    
    var onResponseClosure: ((T?)->())?
    var onApiErrorClosure: ((ApiError)->())?
    var onFailureClosure:  ((AFError?,HTTPURLResponse?)->())?
    
    init(onResponse: ((T?)->())? ,
         onApiError: ((ApiError)->())? ,
         onFailure:  ((AFError?,HTTPURLResponse?)->())?) {
        self.onResponseClosure = onResponse
        self.onApiErrorClosure = onApiError
        self.onFailureClosure = onFailure
    }
    
    func onResponse(response: T?) {
        guard let closure = onResponseClosure else {
            print("Undefinded onResponse closure")
            return
        }
        closure(response)
    }
    
    func onApiError(apiError: ApiError) {
        guard let closure = onApiErrorClosure else {
            print("Undefinded onApiError closure")
            return
        }
        print("apiError: \(apiError)")
        print("apiErrorType: \(String(describing: apiError.apiErrorType))")
        print("authorizerResponseCode: \(String(describing: apiError.authorizerResponseCode))")
        print("authorizerResponseMessage: \(String(describing: apiError.authorizerResponseMessage))")
        print("error: \(String(describing: apiError.error))")
        print("message: \(String(describing: apiError.message))")
        closure(apiError)
        
    }
    
    func onFailure(error: AFError?, response: HTTPURLResponse?) {
        guard let closure = onFailureClosure else {
            print("Undefinded onResponse closure")
            return
        }
        closure(error, response)
    }
}

/**
 *
 */
class RestServiceProcessor<T : Encodable, R : Decodable> {
    
    var endpointURL : String
    let method : HTTPMethod
    var headers : HTTPHeaders?
    var pathParams : [String: String]
    var parameters: Parameters?
    
    init(endpointURL : String, method : HTTPMethod) {
        self.endpointURL = endpointURL
        self.method = method
        self.headers = HTTPHeaders()
        pathParams = [:]
    }
    
    /*
     * Add header for request
     */
    func addHeader(name : String, value: String) {
        headers?.add(name: name, value: value)
    }
    
    /*
    * Add path param to build endpoint URL for request.
    */
    func addPathParam(name : String, value: String) {
        pathParams[name] = value
    }
    
    /*
     * Build the final URL Path for REST Call by replacing the {param} ocurrences for values specified
     */
    private func buildPathParams() {
        var newURL = self.endpointURL
        for (key,value) in pathParams {
            guard newURL.contains("{\(key)}") else {
                print("Unsupported path param {\(key)} in endpoint")
                return
            }
            newURL = newURL.replacingOccurrences(of: "{\(key)}", with: value)
        }
        self.endpointURL = newURL
    }
    
    /*
     * Prepare request using body, path params and headers to invoke Rest Server. The response will be handled using the generic handler via
     * handleResponse method and with the custom callback
     *
     * @param request object to be used as body.
     * @param custom RestCallback to handle success, failure or apiError
     */
    func invoke(request: T?, callback: RestCallback<R>) {
        buildPathParams()
        if let request = request {
            AF.request(endpointURL,
            method: method,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                self.handleResponse(response: response,
                                    callback: callback)
            }
        }
    }
    
    /*
    * Prepare request using path params and headers to invoke Rest Server. The response will be handled using the generic handler via
    * handleResponse method and with the custom callback. This case not use body in the request. This case is suitable for get calls.
    *
    * @param request object to be used as body.
    * @param custom RestCallback to handle success, failure or apiError
    */
    func invoke(callback: RestCallback<R>) {
        buildPathParams()
        AF.request(endpointURL,
            method: method,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                self.handleResponse(response: response,
                                   callback: callback)
            }
    }
    
    /*
     * Handles at high level the response coming from Rest Server
     *
     * @param  response from rest server
     * @callback: custom RestCallback to handle success, failure or apiError
     */
    private func handleResponse(response: AFDataResponse<Any>, callback: RestCallback<R>) {
        print("debugDescription \(response.debugDescription)")
        print("description \(response.description)")
        print("statusCode \(String(describing: response.response?.statusCode))")
        let jsonDecoder = JSONDecoder()
        switch(response.result) {
            case .success(let _):
                if( (response.response!.statusCode)/100 == 2 ){
                    do {
                        if let data = response.data, !data.isEmpty {
                            let custResponse = try jsonDecoder.decode(R.self, from: data)
                            callback.onResponse(response: custResponse)
                        } else {
                            callback.onResponse(response: nil)
                        }
                    } catch let error {
                        // TO-DO: Validate better this case.
                        print("Failure trying to parse Response: \(error)")
                        callback.onFailure(error: response.error, response: response.response)
                    }
                } else {
                    do {
                        let apiError = try jsonDecoder.decode(ApiError.self, from: response.data!)
                        callback.onApiError(apiError: apiError)
                    } catch let error {
                        // TO-DO: Validate better this case
                        print("Failure trying to parse apiError: \(error)")
                        callback.onFailure(error: response.error, response: response.response)
                    }
                }
                break;
                
            case .failure(let error):
                // Empty response but valid case
                if let statusCode = response.response?.statusCode {
                    if (statusCode <= 200 && statusCode < 300) {
                        callback.onResponse(response: nil)
                        break;
                    }
                }
                
                do {
                    if let data = response.data {
                        let apiError = try jsonDecoder.decode(ApiError.self, from: data)
                        callback.onApiError(apiError: apiError)
                    } else {
                        debugPrint("Unexpected: response.data is nil")
                        callback.onFailure(error: response.error, response: response.response)
                    }
                    break;
                } catch let error {
                    print("Failure trying to parse apiError: \(error)")
                    callback.onFailure(error: response.error, response: response.response)
                }
                
                print("errorDescription \(String(describing: error.errorDescription))")
                print("failedStringEncoding \(String(describing: error.failedStringEncoding))")
                callback.onFailure(error: error, response: response.response)
                break;
        }
    }
    
}
