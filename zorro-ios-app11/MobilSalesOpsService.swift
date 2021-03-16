//
//  MobilSalesOpsService.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 10/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import Alamofire

public class MobileSalesOpsService  : AbstractRestService {
   private let MO_GET_CUSTOMER_ENDPOINT:String = "/customer"
   private let MO_GET_MODULES_ENDPOINT:String = "/modules"
   private let MO_GET_STORE_ENDPOINT:String = "/store"
   private let MO_GET_STORE_BALANCE_ENDPOINT:String = "/store/balance"
   private let MO_GET_TAE_PRODUCTS_ENDPOINT:String = "/taeproducts"
   private let MO_TAE_SALE_ENDPOINT:String = "/tae-sale"
    
   private let MO_FIND_TXN_BY_DATE_PAGEABLE_ENDPOINT:String = "/transactionsByDatePageable/{startDateString}/{endDateString}"
   private let SL_TAE_STATUSES_ENDPOINT:String = "/tae-sale/statuses"
    
   private static var singleton:MobileSalesOpsService?
    
   static func getInstance() -> MobileSalesOpsService {
       guard singleton != nil else {
           singleton = MobileSalesOpsService()
           return singleton!
       }
       return singleton!
   }
   
   /*
    *
    */
    func getCustomerInfo(callback: RestCallback<CustomerDto>) {
        let endpointURL = getEndpointUrl(path: MO_GET_CUSTOMER_ENDPOINT)
        let processor = RestServiceProcessor<String, CustomerDto>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
        
    }
    
    /*
     *
     */
    func getModulesInfo(callback: RestCallback<EnabledModules>) {
        let endpointURL = getEndpointUrl(path: MO_GET_MODULES_ENDPOINT)
        let processor = RestServiceProcessor<String, EnabledModules>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
    
    /*
     *
     */
    func getStoreInfo(callback: RestCallback<StoreDto>) {
        let endpointURL = getEndpointUrl(path: MO_GET_STORE_ENDPOINT)
        let processor = RestServiceProcessor<String, StoreDto>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
    
    func getStoreBalance(callback: RestCallback<[CustomerBalanceDto]>) {
        let endpointURL = getEndpointUrl(path: MO_GET_STORE_BALANCE_ENDPOINT)
        let processor = RestServiceProcessor<String, [CustomerBalanceDto]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
    /*
     *
     */
    func getTaeProducts(callback: RestCallback<[TaeProductDto]>) {
        let endpointURL = getEndpointUrl(path: MO_GET_TAE_PRODUCTS_ENDPOINT)
        let processor = RestServiceProcessor<String, [TaeProductDto]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
    /*
     *
     */
    func performSaleTaeOperation(request: TaeSaleRequest,callback: RestCallback<TaeSaleResponse>) {
        let endpointURL = getEndpointUrl(path: MO_TAE_SALE_ENDPOINT)
        let processor = RestServiceProcessor<TaeSaleRequest, TaeSaleResponse>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(request: request, callback: callback)
    }
    
    
    /*
     * Get pageable object with a list objects of customer tae operation
     */
    func findTxnByDatePageable(request: PageableRequest, callback: RestCallback<PageOfCustomerTaeOperation>) {
        let endpointURL = getEndpointUrl(path: MO_FIND_TXN_BY_DATE_PAGEABLE_ENDPOINT)
        let processor = RestServiceProcessor<String, PageOfCustomerTaeOperation>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        let parameters: Parameters = [
            "page": request.page,
            "pageSize": request.pageSize,
            "direction": request.direction,
            "status": request.getStatusString(),
        ]
        
        processor.addPathParam(name: "startDateString", value: request.formatStartDate())
        processor.addPathParam(name: "endDateString", value: request.formatEndDate())
        processor.parameters = parameters
        processor.invoke(callback: callback)
    }
    
    /*
     *
     */
    func getAvailableStatus(callback: RestCallback<[AvailableOption]>) {
        let endpointURL = getEndpointUrl(path: SL_TAE_STATUSES_ENDPOINT)
        let processor = RestServiceProcessor<String, [AvailableOption]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
}
