//
//  AbstractAuthenticationViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 20/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

class AbstractAuthenticationViewController: AbstractUIViewController, PopUpDelegate {
    
    var authenticationService : AuthenticationService = AuthenticationService.getInstance()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @objc func confirmChangePassword() {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = "Importante"
        popup.positiveButtonLabel = "Aceptar"
        popup.negativeButtonLabel = "Cancelar"
        
        let textlbl = UILabel()
        textlbl.textColor = UIColor(named: "colorPrimaryDark")
        textlbl.font = UIFont.systemFont(ofSize: 20)
        textlbl.textAlignment = .left
        textlbl.numberOfLines = 0
        textlbl.minimumScaleFactor = 0.5
        textlbl.adjustsFontSizeToFitWidth = true
        textlbl.text = "¿Estas seguro que deseas crear una nueva contraseña para poder ingresar a la aplicación?"
            
        popup.fixedHeightSizePer = 0.30
        popup.content = textlbl
        
        popup.popUpDelegate = self
            
        self.present(popup, animated: true)
    }
    

    func onPossitiveAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        debugPrint("[AbstractAuthenticationViewController] onPossitiveAction")
        if let rcontroller = controller as? ResetPasswordFormViewController {
            guard let redIdStr = rcontroller.npRedId.text, !redIdStr.isEmpty else {
                rcontroller.showAlert(message: "El campo RedId es requerido")
                return
            }
            
            guard let userStr = rcontroller.npUser.text, !userStr.isEmpty else {
                rcontroller.showAlert(message: "El campo Usuario es requerido")
                return
            }

            popup.dismiss(animated: true)
            DispatchQueue.background(delay: 1.0, completion:{
                var initiatePasswordChangeRequest = InitiatePasswordChangeRequest()
                initiatePasswordChangeRequest.redId = redIdStr
                initiatePasswordChangeRequest.storeUserName = userStr
                // Send for Change Password Request
                self.authenticationService.requestChangePassword(request: initiatePasswordChangeRequest, callback: self.getRequestPwdCallback())
            })
        } else {
            popup.dismiss(animated: true)
            let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
            let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
            popup.customTitle = "Recuperación"
            popup.positiveButtonLabel = "Enviar"
            popup.negativeButtonLabel = "Cancelar"

            let resetPasswordFormViewController = ResetPasswordFormViewController()
            //sendReceiptController.customerReceiptRequest.clientUUID = self.transactionResponseObj?.clientUUID
            //sendReceiptController.customerReceiptRequest.janoUUID = self.transactionResponseObj?.janoUUID
            //sendReceiptController.titleLabel.text = "Email"
            resetPasswordFormViewController.subjectLabel.text = "Por favor, ingrese sus datos para renovar su contraseña"
            
            
            popup.popUpDelegate = self
            popup.controller = resetPasswordFormViewController
            popup.fixedHeightSizePer = 0.45
            self.present(popup, animated: true)
        }
    }
    
    func onNegativeAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        
    }
    
    func onCloseAction(observerId : Notification.Name?, controller : UIViewController?, popup: CustomPopUpViewController) {
        
    }
    
    func getRequestPwdCallback() ->RestCallback<String> {
        let onResponse : ((String?) -> ())? = { response in
            debugPrint("response \(String(describing: response))")
            
            ////////////////////////////////////////////////////////////////////////////////
            self.performTransitionWithIdentifier(identifier: "firstLoginTrans")
            ////////////////////////////////////////////////////////////////////////////////
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error enviando recibo - Message "
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            debugPrint("\(smsg): \(msg)")
            self.showAlert(message: "Ocurrio un error enviando petición para renovar password.")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            debugPrint("error \(String(describing: error))")
            debugPrint("errorDescription \(String(describing: error?.errorDescription))")
            debugPrint("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            debugPrint("destinationURL \(String(describing: error?.destinationURL))")
            
            debugPrint("response \(String(describing: response))")
            debugPrint("statusCode \(String(describing: response?.statusCode))")
            
            self.showAlert(message: "Ocurrio un error enviando petición para renovar password. Verifique su conexión a internet. - \(String(describing: error?.errorDescription))")
        }
        return RestCallback<String>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let transition = TransitionsViews(rawValue: identifier)
        switch transition {
            case .firstLoginTrans:
                let target = storyboard.instantiateViewController(withIdentifier: "firstLogin") as! FirstLoginViewController
                target.isPwdChange = true
                self.navigationController!.pushViewController(target, animated: true)
                var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
                navStackArray.remove(at: navStackArray.count - 2)
                self.navigationController?.setViewControllers(navStackArray, animated: true)
                break
                
            default:
                super.performSegue(withIdentifier: identifier, sender: sender)

        }
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
