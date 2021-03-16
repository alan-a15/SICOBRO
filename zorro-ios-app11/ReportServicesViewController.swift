//
//  ReportServicesViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 18/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

class ReportServicesViewController: GenericReportViewController<ServicePaymentTransaction,PageOfServicePaymentTransaction> {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func getFilterAvailableOptions(callback: RestCallback<[AvailableOption]>) {
        servicesPaymentService.getStatuses(callback: callback)
    }

    override func invokeRestForTxns(pageableRequest: PageableRequest) {
        servicesPaymentService.findTxnByDatePageable(request: pageableRequest, callback: getCallbackPageable(currentPage: pageableRequest.page)!)
    }

    override func getCallbackPageable(currentPage: Int) -> RestCallback<PageOfServicePaymentTransaction>? {
        let onResponse : ((PageOfServicePaymentTransaction?) -> ())? = { response in
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
          
        return RestCallback<PageOfServicePaymentTransaction>(onResponse: onResponse,
                                                             onApiError: apiError,
                                                             onFailure: onFailure)
    }

    override func configureCell(cell: ReportRowCellView<ServicePaymentTransaction>, element: ServicePaymentTransaction){
        if let createdaAt = element.createdAt {
            FORMAT_DATE.dateFormat = MODEL_SHOR_DATE_FORMAT
            cell.label1.text = FORMAT_DATE.string(from: createdaAt.date)
        } else{
            cell.label1.text = "-"
        }
        
        var account = "-"
        if let saccount = element.account {
            account = saccount
        }
        
        var company = "-"
        if let scompany = element.productName {
            company = scompany
        }
        
        var samount = "$ -"
        if let amount = element.amount {
            let ramount = Double(amount / 100)
            samount = Utils.formatCurrency(number: ramount)
        }
        
        if let amount = element.amountLabel {
            samount = amount
        }
        
        var txnStatus = "-"
        if let stxnStatus = element.txnStatusLabel {
            txnStatus = stxnStatus
        }
        
        cell.label2.text = company
        cell.label3.text = samount
        
        var colorId = "colorPrimaryDark"
        var error = false
        if let rcode = element.responseCode {
            //error = rcode != "00"
            error = rcode != "0"    // Code is now 0 instead of 00?
        }
        if(
            (element.responseCode == nil) || error
            
        ) {
            colorId = "helperColor"
        }
        
        let itemColor = UIColor(named: colorId)
        cell.label1.textColor = itemColor
        cell.label2.textColor = itemColor
        cell.label3.textColor = itemColor
    }

    override func prepareDetailItem(item : ServicePaymentTransaction?) -> [SummaryItem] {
        var summaryValues : [SummaryItem] = []
        if let item = item {
            var samount = "$ -"
            /*
            if let amount = item.amount {
                let ramount = Double(amount / 100)
                samount = Utils.formatCurrency(number: ramount)
            }
             */
            if let amount = item.amountLabel {
                samount = amount
            }

            var product = "-"
            if let productName = item.productName {
                product = productName
            }

            var account = "-"
            if let saccount = item.account {
                account = saccount
            }

            var txnStatus = "-"
            if let txnStatusLabel = item.txnStatusLabel {
                txnStatus = txnStatusLabel
            }
            
            var responseMessage = "-"
            if let sresponseMessage = item.responseMessage {
                responseMessage = sresponseMessage
            }

            var responseCode = "-"
            if let sresponseCode = item.responseCode {
                responseCode = sresponseCode
            }
            
            var approvalCode = "-"
            if let sapprovalCode = item.approvalCode {
                approvalCode = sapprovalCode
            }
            
            var sdate = "--"
            if let createdaAt = item.createdAt {
                FORMAT_DATE.dateFormat = MODEL_SHOR_DATE_FORMAT
                sdate = FORMAT_DATE.string(from: createdaAt.date)
            }

        
            summaryValues.append(SummaryItem(name: "Producto:",value: product))
            summaryValues.append(SummaryItem(name: "Referencia:",value: account))
            summaryValues.append(SummaryItem(name: "Monto:",value: samount))
            summaryValues.append(SummaryItem(name: "Estatus:",value: txnStatus))
            summaryValues.append(SummaryItem(name: "Authorización:",value: approvalCode))
            summaryValues.append(SummaryItem(name: "Fecha:",value: sdate))
            summaryValues.append(SummaryItem(name: "Código:",value: responseCode))
            summaryValues.append(SummaryItem(name: "Mensaje:",value: responseMessage))
        }
        debugPrint("summaryValues count from prepareDetailItem: \(summaryValues.count)")
        return summaryValues
    }

    override func getDetailTitle() -> String {
        return "Detalle de Pago de Servicios"
    }
    
    override func getEstimatedRowSize() -> CGFloat {
        return 22.0
    }

    override func setHeadersTitles(cell: ReportRowCellView<ServicePaymentTransaction>){
        cell.label1.text = "Fecha"
        cell.label2.text = "Producto"
        cell.label3.text = "Monto"
    }

    override func getSectionType() -> FragmentSection {
        return FragmentSection.PAGO_SERVICIOS
    }


}
