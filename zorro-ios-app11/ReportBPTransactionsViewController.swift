//
//  ReportBPTransactionsViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 18/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

class ReportBPTransactionsViewController: GenericReportViewController<ReportBillpocketTxn,PageOfReportBillpocketTxn> {

    let APPROVED = "aprobada"
    let DEPOSITO = "deposito"
    let DEPOSITOO = "depósito"
    let TABLE_NAME = "BillPocketResponse"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

    override func getFilterAvailableOptions(callback: RestCallback<[AvailableOption]>) {
        billPocketService.bpGetTxnStatuses(callback: callback)
    }
    
    override func invokeRestForTxns(pageableRequest: PageableRequest) {
        billPocketService.bpFindTxnByDatePageable(request: pageableRequest, callback: getCallbackPageable(currentPage: pageableRequest.page)!)
    }
    
    override func getCallbackPageable(currentPage: Int) -> RestCallback<PageOfReportBillpocketTxn>? {
        let onResponse : ((PageOfReportBillpocketTxn?) -> ())? = { response in
            debugPrint("response \(String(describing: response))")
            //debugdebugPrint("[DEBUG] Retrieving txns successfully [\(response.)]")
            debugPrint("[DEBUG] Pageable Object:")
            debugPrint("isEmpty: \(response?.empty ?? false)")
            debugPrint("isFirst [\(response?.first ?? false)]")
            debugPrint("isLast: \(response?.last ?? false)")
            debugPrint("numberOfPage: \(String(describing: response?.number!))")
            debugPrint("totalPages: \(response?.totalPages ?? -1)")
            debugPrint("totalElements: \(response?.totalElements ?? -1)")
            debugPrint("numberOfElements [\(response?.numberOfElements ?? -1)]")
            debugPrint("sort [\(String(describing: response?.sort))]")

            // Last page?
            self.isLastPage = response?.last ?? true
            
            // Adding Items and Refresh
            if let content = response?.content {
                self.elements.append(contentsOf: content)
            }
            
            // Set Total elements and extra loading row if the current are not the total ones
            self.totalElements = self.elements.count
            if (self.elements.count < (response?.totalElements!)!) {
                self.totalElements += 1
            }
            
            // Notify fetch of pager is completed
            self.onFetchCompleted(totalElementsInPager: (response?.totalElements)!,
                                  isError: false,
                                  msg: nil)
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error obteniendo los ultimos reportes."
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
            self.onFetchCompleted(totalElementsInPager: 0,
                                  isError: true,
                                  msg: nil)
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            self.genericOnFailure(error: error, response: response)
            self.onFetchCompleted(totalElementsInPager: 0,
                                  isError: true,
                                  msg: "Verifique su conexión o contacte al administrador.")
        }
          
        return RestCallback<PageOfReportBillpocketTxn>(onResponse: onResponse,
                                                        onApiError: apiError,
                                                        onFailure: onFailure)
    }
    
    override func configureCell(cell: ReportRowCellView<ReportBillpocketTxn>, element: ReportBillpocketTxn){
        if let createdaAt = element.txnLocalDateTime {
            FORMAT_DATE.dateFormat = MODEL_SHOR_DATE_FORMAT
            cell.label1.text = FORMAT_DATE.string(from: createdaAt.date)
        } else{
            cell.label1.text = "-"
        }
        
        var authNumber = "-"
        if let sauthNumber = element.authorizationNumber {
            authNumber = sauthNumber
        }
        
        var samount = "-"
        if let amount = element.amount {
            samount = amount
        }
        
        var result = "Desconocido"
        if let sresult = element.result {
            result = sresult
        }
        
        cell.label2.text = samount
        cell.label3.text = result
        
        var colorId = "helperColor"
        if let sresult = element.result {
            let rresult = sresult.lowercased()
            if ( rresult == APPROVED.lowercased() ) {
                colorId = "colorPrimaryDark"
            } else if ( rresult == DEPOSITO.lowercased() || rresult == DEPOSITOO.lowercased() ) {
                colorId = "helperColor2"
            } else {
                colorId = "helperColor"
            }
        }
        
        let itemColor = UIColor(named: colorId)
        cell.label1.textColor = itemColor
        cell.label2.textColor = itemColor
        cell.label3.textColor = itemColor
    }
    
    override func prepareDetailItem(item : ReportBillpocketTxn?) -> [SummaryItem] {
        var summaryValues : [SummaryItem] = []
        if let item = item {
            var id = "-"
            if let sid = item.id {
                id = "\(sid)"
            }

            var status = "-"
            if let result = item.result {
                status = result
            }

            var message = "-"
            if let statusinfo = item.statusinfo {
                message = statusinfo
            }

            var bank = "-"
            if let sbank = item.bank {
                bank = sbank
            }
            
            var authorizationNumber = "-"
            if let sauthorizationNumber = item.authorizationNumber {
                authorizationNumber = sauthorizationNumber
            }
            
            var amount = "-"
            if let samount = item.amount {
                amount = samount
            }

            var creditcard = "-"
            if let screditcard = item.creditcard {
                creditcard = screditcard
            }

            var cardtype = "-"
            if let scardtype = item.cardtype {
                cardtype = scardtype
            }
            
            var sdate = "-"
            if let ssdate = item.txnLocalDateTime {
                sdate = Utils.format(date: ssdate.date, withFormatString: Utils.MODEL_DATE_FORMAT)
            }
            
            var error = true
            if let sresult = item.result {
                let rresult = sresult.lowercased()
                error = rresult != APPROVED.lowercased()
            }
            
            summaryValues.append(SummaryItem(name: "Id:",value: id))
            summaryValues.append(SummaryItem(name: "Estatus:",value: status))
            if (error) {
                summaryValues.append(SummaryItem(name: "Mensaje:",value: message))
            } else {
                summaryValues.append(SummaryItem(name: "Monto:",value: amount))
                summaryValues.append(SummaryItem(name: "Folio Auth:",value: authorizationNumber))
                summaryValues.append(SummaryItem(name: "Banco:",value: bank))
                summaryValues.append(SummaryItem(name: "Tarjeta:",value: creditcard))
                summaryValues.append(SummaryItem(name: "Tipo:",value: cardtype))
                summaryValues.append(SummaryItem(name: "Fecha:",value: sdate))
            }
        }
        debugPrint("summaryValues count from prepareDetailItem: \(summaryValues.count)")
        return summaryValues
    }
    
    override func getDetailTitle() -> String {
        return "Detalle de Transacción"
        
    }
    
    override func setHeadersTitles(cell: ReportRowCellView<ReportBillpocketTxn>){
        cell.label1.text = "Fecha"
        cell.label2.text = "Monto"
        cell.label3.text = "Estatus"
    }
    
    override func getSectionType() -> FragmentSection {
        return FragmentSection.COBROS
    }

}
