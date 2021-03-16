//
//  BillPocketService.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 10/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import Foundation
import Alamofire

public class BillPocketService : AbstractRestService {
    private let BP_ISACTIVE_ENDPOINT:String = "/billpocket/status"
    private let BP_ACTIVATE_BILLPOCKET_ENDPOINT:String = "/billpocket/activate"
    private let BP_SAVE_BILLPOCKET_TXN_ENDPOINT:String = "/billpocket/transaction"
    private let BP_FIND_BY_STORE_ENDPOINT:String = "/billpocket/transactions"
    private let BP_FIND_TXN_BY_DATE_ENDPOINT:String = "/billpocket/transactionsByDate/{startDateString}/{endDateString}"
    private let BP_FIND_TXN_BY_DATE_PAGEABLE_ENDPOINT:String = "/billpocket/transactionsByDatePageable/{startDateString}/{endDateString}"
    private let BP_TXN_STATUSES_ENDPOINT:String = "/billpocket/statuses"
    
    private static var singleton:BillPocketService?
    
    static func getInstance() -> BillPocketService {
        guard singleton != nil else {
            singleton = BillPocketService()
            return singleton!
        }
        return singleton!
    }
     
    /*
     *
     */
    func bpIsActive(callback: RestCallback<BillpocketOperationStatusResponse>) {
        let endpointURL = getEndpointUrl(path: BP_ISACTIVE_ENDPOINT)
        let processor = RestServiceProcessor<String,BillpocketOperationStatusResponse>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        
        processor.invoke(callback: callback)
    }

    

    /*
     * DEPRECATED: Not anymore in JANO REST
     */
    func bpActivateBillPocket(callback: RestCallback<BillpocketOperationStatusResponse>) {
        let endpointURL = getEndpointUrl(path: BP_ACTIVATE_BILLPOCKET_ENDPOINT)
        let processor = RestServiceProcessor<String,BillpocketOperationStatusResponse>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        
        processor.invoke(callback: callback)
    }

    /*
     *
     */
    func bpSaveBillPocketTxn(billpocketTxnDto:BillpocketTxnDto, callback: RestCallback<BillpocketTxn>) {
        let endpointURL = getEndpointUrl(path: BP_SAVE_BILLPOCKET_TXN_ENDPOINT)
        let processor = RestServiceProcessor<BillpocketTxnDto,BillpocketTxn>(endpointURL: endpointURL, method: .post)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        
        processor.invoke(request: billpocketTxnDto, callback: callback)
    }
    
    /*
     *
     */
    func bpFindByStore(callback: RestCallback<[BillpocketTxn]>) {
        let endpointURL = getEndpointUrl(path: BP_FIND_BY_STORE_ENDPOINT)
        let processor = RestServiceProcessor<String, [BillpocketTxn]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        
        processor.invoke(callback: callback)
    }
        

    /*
     * Get pageable object with a list objects of Billpocket TXN by date
     */
    func bpFindTxnByDate(request: PageableRequest, callback: RestCallback<[BillpocketTxn]>) {
        let endpointURL = getEndpointUrl(path: BP_FIND_TXN_BY_DATE_ENDPOINT)
        let processor = RestServiceProcessor<String, [BillpocketTxn]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        
        processor.addPathParam(name: "startDateString", value: request.formatStartDate())
        processor.addPathParam(name: "endDateString", value: request.formatEndDate())
        processor.invoke(callback: callback)
    }

    
    /*
     * Get pageable object with a list objects of Billpocket TXN
     */
    func bpFindTxnByDatePageable(request: PageableRequest, callback: RestCallback<PageOfReportBillpocketTxn>) {
        let endpointURL = getEndpointUrl(path: BP_FIND_TXN_BY_DATE_PAGEABLE_ENDPOINT)
        let processor = RestServiceProcessor<String, PageOfReportBillpocketTxn>(endpointURL: endpointURL, method: .get)
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
    func bpGetTxnStatuses(callback: RestCallback<[AvailableOption]>) {
        let endpointURL = getEndpointUrl(path: BP_TXN_STATUSES_ENDPOINT)
        let processor = RestServiceProcessor<String, [AvailableOption]>(endpointURL: endpointURL, method: .get)
        addJanoHeaders(processor: processor, headerNames: [AbstractRestService.APPVERSION_HEADER,
                                                            AbstractRestService.DEVICEID_HEADER,
                                                            AbstractRestService.SESSIONTOKEN_HEADER])
        processor.invoke(callback: callback)
    }
    
}
