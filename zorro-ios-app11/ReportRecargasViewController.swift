//
//  ReportRecargasViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 15/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

class ReportRecargasViewController: GenericReportViewController<CustomerTaeOperation,PageOfCustomerTaeOperation> {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func getFilterAvailableOptions(callback: RestCallback<[AvailableOption]>) {
        mobileSalesOpsService.getAvailableStatus(callback: callback)
    }
    
    override func invokeRestForTxns(pageableRequest: PageableRequest) {
        mobileSalesOpsService.findTxnByDatePageable(request: pageableRequest,
                                                    callback: getCallbackPageable(currentPage: pageableRequest.page)!)
    }
    
    override func getCallbackPageable(currentPage: Int) -> RestCallback<PageOfCustomerTaeOperation>? {
        let onResponse : ((PageOfCustomerTaeOperation?) -> ())? = { response in
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
          
        return RestCallback<PageOfCustomerTaeOperation>(onResponse: onResponse,
                                                        onApiError: apiError,
                                                        onFailure: onFailure)
    }
    
    override func configureCell(cell: ReportRowCellView<CustomerTaeOperation>, element: CustomerTaeOperation){
        if element.createdAt != nil {
            FORMAT_DATE.dateFormat = MODEL_SHOR_DATE_FORMAT
            cell.label1.text = FORMAT_DATE.string(from: element.createdAt!.date)
        } else{
            cell.label1.text = "-"
        }
        
        var saccount = "-"
        if let account = element.account {
            saccount = account
        }
        
        var samount = "$ -"
        if let amount = element.amount {
            let aamount = Double(amount / 100)
            samount = Utils.formatCurrency(number: aamount)
        }
        
        /*
        var sstatus = "-"
        if let txnStatusLabel = element.txnStatusLabel {
            sstatus = txnStatusLabel
        }*/
        
        cell.label2.text = saccount
        cell.label3.text = samount
        
        var colorId = "colorPrimaryDark"
        var error = false
        if let rcode = element.responseCode {
            error = rcode != "00"
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
    
    override func prepareDetailItem(item : CustomerTaeOperation?) -> [SummaryItem] {
        var summaryValues : [SummaryItem] = []
        if let item = item {
            var samount = "$ -"
            if( item.amount != nil ) {
                let amount = (item.amount ?? 0) / 100
                samount = Utils.formatCurrency(number: Double(amount))
            }

            var company = "-"
            if let productName = item.productName {
                company = productName
            }

            var sphone = "-"
            if let account = item.account {
                sphone = account
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
            
            var sdate = "-"
            if let ssdate = item.createdAt {
                sdate = Utils.format(date: ssdate.date, withFormatString: Utils.MODEL_DATE_FORMAT)
            }
            
            summaryValues.append(SummaryItem(name: "Compañia:",value: company))
            summaryValues.append(SummaryItem(name: "Teléfono:",value: sphone))
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
        return "Detalle de Recarga"
        
    }
    
    override func setHeadersTitles(cell: ReportRowCellView<CustomerTaeOperation>){
        cell.label1.text = "Fecha"
        cell.label2.text = "Telefono"
        cell.label3.text = "Monto"
    }
    
    override func getSectionType() -> FragmentSection {
        return FragmentSection.RECARGAS
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
