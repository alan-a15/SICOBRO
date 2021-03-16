//
//  ServicesPaymentService.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 10/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import Alamofire


public class ServicesPaymentService  : AbstractRestService {
    
    // Catalog
    private let CAT_INDEX_ENDPOINT:String = "/"
    private let CAT_FIND_SEGMENTS_ENDPOINT:String = "/segments"
    private let CAT_FIND_PRODUCTS_ENDPOINT:String = "/segment/{segmentId}/products"

    // Reports
    private let REP_STATUSES_ENDPOINT:String = "/statuses"
    private let REP_FIND_TXN_BY_DATE_ENDPOINT:String = "/transactionsByDate/{startDateString}/{endDateString}"
    private let REP_FIND_TXN_BY_DATE_EXCEL_ENDPOINT:String = "/transactionsByDate/excel/{startDateString}/{endDateString}"
    private let REP_FIND_TXN_BY_DATE_PAGEABLE_ENDPOINT:String = "/transactionsByDatePageable/{startDateString}/{endDateString}"

    // Transacciones
    private let TXN_APPLY_TRANSACTION_ENDPOINT:String = "/applyTransaction"
    private let TXN_PREPARE_TRANSACTION_ENDPOINT:String = "/prepareTransaction"
    private let TXN_SEND_CUSTOMER_RECEIPT_ENDPOINT:String = "/send-customer-receipt"
    
    
    private static var singleton:ServicesPaymentService?
    
    static func getInstance() -> ServicesPaymentService {
        guard singleton != nil else {
            singleton = ServicesPaymentService()
            return singleton!
        }
        return singleton!
    }
    
    /** Catalog Endpoints **/
    /*
     *
     */
    func getCatalogIndex(callback: RestCallback<String>) {
        let endpointURL = self.getEndpointUrl(path: CAT_INDEX_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<String,String>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        
        processor.invoke(callback: callback)
    }

    /*
     *
     */
    func getSegments(callback: RestCallback<[Segment]>) {
        let endpointURL = self.getEndpointUrl(path: CAT_FIND_SEGMENTS_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<String,[Segment]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        
        processor.invoke(callback: callback)
    }

    /*
     *
     */
    func getProducts(segmentId: Int, callback: RestCallback<[ProductDto]>) {
        let endpointURL = self.getEndpointUrl(path: CAT_FIND_PRODUCTS_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<String,[ProductDto]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.addPathParam(name: "segmentId", value:"\(segmentId)")
        processor.invoke(callback: callback)
    }
    
    
    /** Reports Endpoints **/
    /*
     *
     */
    func getStatuses(callback: RestCallback<[AvailableOption]>) {
        let endpointURL = self.getEndpointUrl(path: REP_STATUSES_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<String,[AvailableOption]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
    /*
     *
     */
    func findTxnByDate(request: PageableRequest, callback: RestCallback<[ServicePaymentTransaction]>) {
        let endpointURL = self.getEndpointUrl(path: REP_FIND_TXN_BY_DATE_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<String,[ServicePaymentTransaction]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.addPathParam(name: "startDateString", value: request.formatStartDate())
        processor.addPathParam(name: "endDateString", value: request.formatEndDate())
        processor.invoke(callback: callback)
    }
    
    /*
     *
     */
    func findTxnByDateExcel(request: PageableRequest, callback: RestCallback<ReportResponse>) {
        let endpointURL = self.getEndpointUrl(path: REP_FIND_TXN_BY_DATE_EXCEL_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<String,ReportResponse>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.addPathParam(name: "startDateString", value: request.formatStartDate())
        processor.addPathParam(name: "endDateString", value: request.formatEndDate())
        processor.invoke(callback: callback)
    }
     
    /*
     *
     */
    func findTxnByDatePageable(request: PageableRequest, callback: RestCallback<PageOfServicePaymentTransaction>) {
        let endpointURL = self.getEndpointUrl(path: REP_FIND_TXN_BY_DATE_PAGEABLE_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<String,PageOfServicePaymentTransaction>(endpointURL: endpointURL, method: .get)
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

    /** Transactions API Endpoints **/
    /*
     *
     */
    func prepareTransaction(request: PrepareTxnRequest, callback: RestCallback<PrepareTxnResponse>) {
        let endpointURL = self.getEndpointUrl(path: TXN_PREPARE_TRANSACTION_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<PrepareTxnRequest,PrepareTxnResponse>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(request: request, callback: callback)
    }
    
    /*
     *
     */
    func applyTransaction(request: TransactionRequest, callback: RestCallback<TransactionResponse>) {
        let endpointURL = self.getEndpointUrl(path: TXN_APPLY_TRANSACTION_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<TransactionRequest,TransactionResponse>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(request: request, callback: callback)
    }
    
    /*
     *
     */
    func sendCustomerReceipt(request: CustomerReceiptRequest, callback: RestCallback<String>) {
        let endpointURL = self.getEndpointUrl(path: TXN_SEND_CUSTOMER_RECEIPT_ENDPOINT, isPaymentServices: true)
        let processor = RestServiceProcessor<CustomerReceiptRequest,String>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        request.clientVersion = settings.appversion
        processor.invoke(request: request, callback: callback)
    }
}
