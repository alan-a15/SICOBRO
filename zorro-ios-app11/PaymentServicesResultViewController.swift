//
//  PaymentServicesResultViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 20/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

class PaymentServicesResultViewController:AbstractResultViewController, PostOperationAction, PopUpDelegate {

    var progressWheel:ProgressWheelPopUp?
    var transactionResponseObj : TransactionResponseObj?
    
    func postAction(abstractResultViewController : AbstractResultViewController) {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = "Enviar Recibo"
        popup.positiveButtonLabel = "Enviar"
        popup.negativeButtonLabel = "Cancelar"

        let sendReceiptController = SendReceiptViewController()
        sendReceiptController.customerReceiptRequest.clientUUID = self.transactionResponseObj?.clientUUID
        sendReceiptController.customerReceiptRequest.janoUUID = self.transactionResponseObj?.janoUUID
        sendReceiptController.titleLabel.text = "Email"
        
        popup.popUpDelegate = abstractResultViewController as? PopUpDelegate
        popup.controller = sendReceiptController
        popup.fixedHeightSizePer = 0.35
        self.present(popup, animated: true)
    }
    
    func onPossitiveAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        debugPrint("[PaymentServicesResultViewController] onPossitiveAction")
        guard let scontroller = controller else {
            debugPrint("[PaymentServicesResultViewController] controller \(controller)")
            return
        }
        
        let rcontroller:SendReceiptViewController = scontroller as! SendReceiptViewController
        guard let emailInputStr = rcontroller.emailInput.text, !emailInputStr.isEmpty else {
            rcontroller.showAlert(message: "El campo email es requerido")
            return
        }

        let customerReceiptRequest = rcontroller.customerReceiptRequest
        customerReceiptRequest.email = emailInputStr
        servicesPaymentService.sendCustomerReceipt(request: customerReceiptRequest, callback: getSendCustomerReceiptCallback())
        
        popup.dismiss(animated: true)
        
        progressWheel = ProgressWheelPopUp(text: "Enviando Recibo... ")
        self.view.addSubview(progressWheel!)
    }
    
    func onNegativeAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        
    }
    
    func onCloseAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        
    }
    
    private func getSendCustomerReceiptCallback() -> RestCallback<String> {
        let onResponse : ((String?) -> ())? = { response in
            if let progressWheel = self.progressWheel {
                progressWheel.hide()
            }
            debugPrint("response \(String(describing: response))")
            
            ////////////////////////////////////////////////////////////////////////////////
            self.showAlert(message: "Recibo enviado")
            ////////////////////////////////////////////////////////////////////////////////
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            if let progressWheel = self.progressWheel {
                progressWheel.hide()
            }
            let smsg = "Ocurrio un error enviando recibo - Message "
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            debugPrint("\(smsg): \(msg)")
            self.showAlert(message: "Ocurrio un error enviando recibo.")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            if let progressWheel = self.progressWheel {
                progressWheel.hide()
            }
            debugPrint("error \(String(describing: error))")
            debugPrint("errorDescription \(String(describing: error?.errorDescription))")
            debugPrint("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            debugPrint("destinationURL \(String(describing: error?.destinationURL))")
            
            debugPrint("response \(String(describing: response))")
            debugPrint("statusCode \(String(describing: response?.statusCode))")
            
            self.showAlert(message: "Ocurrio un error enviando recibo. Verifique su conexión a internet. - \(String(describing: error?.errorDescription))")
        }
        return RestCallback<String>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
}
