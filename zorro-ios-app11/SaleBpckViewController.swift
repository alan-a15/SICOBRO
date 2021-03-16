//
//  SaleBpckViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 21/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

class SaleBpckViewController: SICobroViewController, ExtensionKeyboardActions {

    @IBOutlet weak var inputAmount: IconedUITextField!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var btnSubmit: CustomRoundedButton!
    
    //private let urlScheme = "zorroios://" //"billpocket://"
    private let urlScheme = "billpocket://"
    
    //private let zorroSchema = "zorroios"
    private let zorroSchema = "zorroios.reader"
    
    private var bpckTxnDto:BillpocketTxnDto?
    
    private var waitForBPKCResponse:Bool = false
    private var bpckParameters : [String:String] = [:]
    
    let APPROVED = "aprobada"
    let DEPOSITO = "deposito"
    let DEPOSITOO = "depósito"
    let TABLE_NAME = "BillPocketResponse"
    
    private let BPCK_PROD_URL = "https://apps.apple.com/mx/app/billpocket/id625596360"
    private let BPCK_DEV_URL = "https://www.billpocket.com/api/v1/mobile/ios/testing/3.4.0/"
    
    // DEV PURPOSES ONLY
    private let FORCE_BPCK_PROD = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        indicator.isHidden = true
        indicator.hidesWhenStopped = true

        self.inputAmount.leftImage = UIImage(named: "pos")
        self.inputAmount.borderColor = UIColor(named: "colorPrimaryDark")
        self.inputAmount.cornerRadius = 6.0
        self.inputAmount.borderWidth = 1.0
        self.inputAmount.leftPadding = 5.0
        self.inputAmount.maxLength = 10
        self.inputAmount.valueType = .currency
        self.inputAmount.delegate = self
        self.inputAmount.keyboardType = .decimalPad
        
        self.btnSubmit.adjustFont(scale: 3.0)
        
        self.keyboardActions = self
        let toolbar = self.getGenericFormToolbar()
        self.inputAmount.inputAccessoryView = toolbar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateBpckApp()
    }
    
    private func validateBpckApp() -> Bool {
        if( !checkBpckIsInstalled() ) {
            let message = "Preparando servicio de cobros ... \nPor favor, siga las instrucciones que se indican.\n\n"
            let alert = UIAlertController(title: "SiCobro TOTAL", message: message, preferredStyle: UIAlertController.Style.alert)
            
            let spinner = UIActivityIndicatorView(style: .gray)
            spinner.center = CGPoint(x: 130.5, y: 110)
            spinner.color = .black
            spinner.startAnimating()
            alert.view.addSubview(spinner)

            // show the alert
            self.present(alert, animated: true, completion: nil)
            
            DispatchQueue.background(delay: 2.0, completion:{
                alert.dismiss(animated: true, completion: {
                    self.tryInstallBpck()
                })
            })
            debugPrint("validateBpckApp: BPCK NOT INSTALLED!")
            return false
        }
        debugPrint("validateBpckApp: BPCK Installed!")
        return true
    }
    
    private func tryInstallBpck() {
        if( Environment.isDev() && !FORCE_BPCK_PROD ) {
            // Open URL Dev URL
            if let url = URL(string: BPCK_DEV_URL) {
                UIApplication.shared.open(url)
            }
        } else {
            // Open App Store URL
            callAppStore()
        }
    }
    
    private func callAppStore() {
        if let url = URL(string: BPCK_PROD_URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if UIApplication.shared.canOpenURL(url as URL) {
                    UIApplication.shared.openURL(url as URL)
                } else {
                    self.showAlert(message: "No fue posible abrir App Store para instalar BillPocket")
                }
            }
        }
    }
    
    @IBAction func submitPayment(_ sender: Any) {
        // Validate if BPCK is active
        debugPrint("btnSubmitCobro clicked")
        if(!self.validateSessions(forwardToInitial: false, destroyCurrentView: true)) {
            return
        }
        
        if( !validateBpckApp() ) {
            return
        }
        
        btnSubmit.isEnabled = false
        billPocketService.bpIsActive(callback: getIsBPCKCallback())
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.inputAmount.adjustFont()
    }
    
    /**
    MARK: keyboard actions
     */
    func keybDoneButton() {
        if self.btnSubmit.isEnabled {
            self.submitPayment(self.btnSubmit!)
        }
    }
    
    func keybPrevButton(sender: UIBarButtonItem) { }
    
    func keybNextButton(sender: UIBarButtonItem) { }
    
    func getIsBPCKCallback() ->RestCallback<BillpocketOperationStatusResponse> {
        let onResponse : ((BillpocketOperationStatusResponse?) -> ())? = { response in
            debugPrint("response \(String(describing: response))")
            
            if let billpocketOperationStatusResponse  = response {
                if (billpocketOperationStatusResponse.status == BillpocketOperationStatusResponse.Status.active ) {
                    if let bpckToken = billpocketOperationStatusResponse.billpocketToken, !bpckToken.isEmpty {
                        debugPrint("Using BPCK token retrieved")
                        debugPrint("BPCK token \(bpckToken)")
                        self.sessionManager.setUserProperty(key: .BPCK_TOKEN, value: bpckToken)
                    }
                    self.invokeBillPocket()
                } else {
                    self.btnSubmit.isEnabled = true
                    debugPrint("BPCK is not active for this user")
                    self.showAlert(message: "BPCK No esta activo para este usuario - Message [\(String(describing: billpocketOperationStatusResponse.statusDetail))]")
                }
            } else {
                self.showAlert(message: "No fue posible validar Servicio de BPCK Activo para el usuario actual")
            }
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            var msg : String? = nil
            var code : String? = nil
            if (apiError.authorizerResponseMessage != nil && !apiError.authorizerResponseMessage!.isEmpty ) {
                msg = apiError.authorizerResponseMessage
            } else if (apiError.message != nil) {
                msg = apiError.message
            }
            if (apiError.authorizerResponseCode != nil  && !apiError.authorizerResponseCode!.isEmpty ) {
                code = apiError.authorizerResponseCode
            } else if (apiError.error != nil) {
                code = apiError.error
            }
            
            debugPrint("Error Message: \(String(describing: msg))")
            debugPrint("Error Code: \(String(describing: code))")
            self.showAlert(message: "Ocurrio un error a obtener estado de bpck")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            debugPrint("error \(String(describing: error))")
            debugPrint("errorDescription \(String(describing: error?.errorDescription))")
            debugPrint("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            debugPrint("destinationURL \(String(describing: error?.destinationURL))")
            debugPrint("response \(String(describing: response))")
            debugPrint("statusCode \(String(describing: response?.statusCode))")
            debugPrint("debugDescription \(String(describing: response?.debugDescription))")
            
            self.showAlert(message: "Ocurrio un error invocando el servicio. Verifique su conexion de red.")
        }
        
        return RestCallback<BillpocketOperationStatusResponse>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    func invokeBillPocket() {
        debugPrint("on invokeBillPocket")
        guard let inputAmountStr = inputAmount.text, !inputAmountStr.isEmpty else {
            self.showAlert(message: "El campo Monto es requerido")
            return
        }
        
        //var bpckParameters : [String:String] = [:]
        let loadedUser = sessionManager.loadUserSession(forceReload: true)
        debugPrint("loadedUser BNPCK Token \(loadedUser?.billpocketToken ?? "NOTDEFINED")")
        
        let randomIdentifier = Utils.generateRandomIdentifier()
        
        bpckParameters["transaction"] = "venta"
        bpckParameters["amount"] = inputAmountStr
        bpckParameters["tip"] = ""
        bpckParameters["reference"] = "Venta - \(randomIdentifier)"
        bpckParameters["msi"] = ""
        bpckParameters["identifier"] = randomIdentifier
        //bpckParameters["urlScheme"] = "zorroios.reader"
        //bpckParameters["urlScheme"] = "zorroios"
        bpckParameters["urlScheme"] = zorroSchema
        bpckParameters["userToken"] = loadedUser?.billpocketToken
        bpckParameters["deviceToken"] = loadedUser?.billpocketDeviceToken
        bpckParameters["isMandatoryPhoto"] = "false"
        bpckParameters["thirdPartyId"] = "--"
        bpckParameters["isHidePrinter"] = "true"
        bpckParameters["isSkipMailPrint"] = "true"
        bpckParameters["isXpLandscape"] = "true"
        
        let bpckPath = String.localizedStringWithFormat("%@transaction=%@&usertoken=%@&amount=%@&reference=%@&identifier=%@&urlScheme=%@",
                                                        urlScheme,
                                                        Utils.prepareStringForURLParam(value: bpckParameters["transaction"]!),
                                                        Utils.prepareStringForURLParam(value: bpckParameters["userToken"]!),
                                                        Utils.prepareStringForURLParam(value: bpckParameters["amount"]!),
                                                        Utils.prepareStringForURLParam(value: bpckParameters["reference"]!),
                                                        Utils.prepareStringForURLParam(value: bpckParameters["identifier"]!),
                                                        Utils.prepareStringForURLParam(value: bpckParameters["urlScheme"]!) )
        
        debugPrint("Calling BPCK with [\(bpckPath)]")
        let bcpkURL = URL(string: bpckPath)
        debugPrint("GeneratedURL [\(String(describing: bcpkURL))]")
        
        // Write code to open URL here:
        if(UIApplication.shared.canOpenURL(bcpkURL!)) {
            UIApplication.shared.open(bcpkURL!) { (result) in
                if result {
                   debugPrint("Result from BPCK call: [\(result)]")
                    self.waitForBPKCResponse = true
                    //self.showAlert(message: "\(result)")
                }
            }
        } else {
            self.showAlert(message: "No fue posible invocar a Billpocket desde Zorro.")
        }
    }
    
    private func checkBpckIsInstalled() -> Bool {
        let bpckPath = String.localizedStringWithFormat("%@://app", urlScheme)
        debugPrint("checkBpckIsInstalled with [\(bpckPath)]")
        
        let bcpkURL = URL(string: bpckPath)
        debugPrint("GeneratedURL [\(String(describing: bcpkURL))]")
        
       return UIApplication.shared.canOpenURL(bcpkURL!)
    }
    
    func handlBillpocketResponse(response: URL) {
        debugPrint("On handlBillpocketResponse")
        
        indicator.startAnimating()
        self.waitForBPKCResponse = false
        
        let sparameter = response.host?.removingPercentEncoding
        debugPrint("url: [\(response.absoluteString)]")
        debugPrint("parameter: [\(String(describing: sparameter))]")
            
        // Parse Response
        /* Example:
            amount=10.00&usertoken=eac1739691853729a01f9350e1c7aa218ebed603b2c4d8ef7213b1651b153e0e&reference=Venta - AB082CA8ECF4&transaction=venta&identifier=AB082CA8ECF4&urlScheme=zorroios.reader&statusinfo=La transacción fue cancelada&result=error
        */
        var txnSuccess = false
        if let parameter = sparameter, !parameter.isEmpty {
            var responseParams : [String:String] = [:]
            
            let responseValues = parameter.components(separatedBy: "&")
            responseValues.forEach({ (it) in
                let paramValue = it.components(separatedBy: "=")
                responseParams[paramValue[0]] = paramValue[1]
            })
            
            if responseParams.isEmpty {
                bpckParameters["statusinfo"] = "Error al parsear respuesta de BPCK"
                bpckParameters["appError"] = "Error al parsear respuesta de BPCK"
            } else {
                bpckParameters["result"] = responseParams["result"]
                txnSuccess = bpckParameters["result"] == APPROVED
                if(!txnSuccess) {
                    bpckParameters["statusinfo"] = responseParams["statusinfo"]
                } else {
                    bpckParameters["amount"] = responseParams["amount"]
                    bpckParameters["tip"] = responseParams["tip"]
                    bpckParameters["reference"] = responseParams["reference"]
                    bpckParameters["transactionid"] = responseParams["transactionid"]
                    bpckParameters["msi"] = responseParams["msi"]
                    bpckParameters["authorization"] = responseParams["authorization"]
                    bpckParameters["creditcard"] = responseParams["creditcard"]
                    bpckParameters["cardtype"] = responseParams["cardtype"]
                    bpckParameters["email"] = responseParams["email"]
                    bpckParameters["phone"] = responseParams["phone"]
                    bpckParameters["arqc"] = responseParams["arqc"]
                    bpckParameters["aid"] = responseParams["aid"]
                    bpckParameters["applabel"] = responseParams["applabel"]
                    bpckParameters["url"] = responseParams["url"]
                    bpckParameters["bank"] = responseParams["bank"]
                    bpckParameters["accountType"] = responseParams["accountType"]
                    bpckParameters["captureMode"] = responseParams["captureMode"]
                }
                bpckParameters["identifier"] = responseParams["identifier"]
            }
        }  else {
            bpckParameters["statusinfo"] = "Respuesta de BPCK vacia"
            bpckParameters["appError"] = "Respuesta de BPCK vacia"
        }
        
        self.parseToBpckObject()
        
        DispatchQueue.background(delay: 0.5, completion:{
            if let bpckTxnDto = self.bpckTxnDto {
                self.billPocketService.bpSaveBillPocketTxn(billpocketTxnDto: bpckTxnDto, callback: self.storeTxnCallback(txnSuccess: txnSuccess))
            } else {
                self.showAlert(message: "Error inesperado mientras se almacenaba la operacion.")
            }
        })
    }
    
    private func storeTxnCallback(txnSuccess: Bool) -> RestCallback<BillpocketTxn> {
        var summaryValues:[SummaryItem] = []
        var smsg = ""
        if (!txnSuccess) {
            smsg = "¡Ups, algo sucedio!"
            summaryValues.append(SummaryItem(name: "Tipo de error:",value: bpckTxnDto?.result ?? "Desconocido"))
            summaryValues.append(SummaryItem(name: "Mensaje de error:",value: bpckTxnDto?.statusinfo ?? "N/A"))
        } else {
            smsg = "¡Tu cobro ha sido realizado con éxito!"
            summaryValues.append(SummaryItem(name: "Transacción:",value: bpckTxnDto?.transactionId ?? "--"))
            summaryValues.append(SummaryItem(name: "Referencia:",value: bpckTxnDto?.reference ?? "--"))
            summaryValues.append(SummaryItem(name: "Autorización:",value: bpckTxnDto?.authorizationNumber ?? "--"))
            summaryValues.append(SummaryItem(name: "Tarjeta:",value: bpckTxnDto?.creditcard ?? "--"))
        }
        
        
        let saleOnResponse : ((BillpocketTxn?) -> ())? = { response in
            print("response \(String(describing: response))")
            
            self.sendSummary(success: txnSuccess, resultMsgTxt: smsg, summaryValues: summaryValues)
        }
        
        let saleApiError : ((ApiError)->())? =  { apiError in
            print("on saleApiError \(String(describing: apiError))")
            
            var msg : String? = nil
            var code : String? = nil
            if (apiError.authorizerResponseMessage != nil && !apiError.authorizerResponseMessage!.isEmpty ) {
                msg = apiError.authorizerResponseMessage
            } else if (apiError.message != nil) {
                msg = apiError.message
            }
            if (apiError.authorizerResponseCode != nil  && !apiError.authorizerResponseCode!.isEmpty ) {
                code = apiError.authorizerResponseCode
            } else if (apiError.error != nil) {
                code = apiError.error
            }
            
            self.showAlert(message: "Ocurrio un error almacenando Txn de Billpocket")
            self.sendSummary(success: txnSuccess, resultMsgTxt: smsg, summaryValues: summaryValues)
        }
        
        let saleOnFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            print("debugDescription \(String(describing: response?.debugDescription))")
            
            self.showAlert(message: "Ocurrio un error almacenando Txn de Billpocket")
            self.sendSummary(success: txnSuccess, resultMsgTxt: smsg, summaryValues: summaryValues)
        }
        
        return RestCallback<BillpocketTxn>(onResponse: saleOnResponse, onApiError: saleApiError, onFailure: saleOnFailure)
    }
    
    private func sendSummary(success: Bool, resultMsgTxt: String, summaryValues: [SummaryItem]) {
        if(parentController != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let target = storyboard.instantiateViewController(withIdentifier: "abstractResultVC") as! AbstractResultViewController
            
            target.resultTitleTxt = "Cobros con TDC/TDD"
            target.repeatButtonTxt = "Realizar otro cobro"
            target.fragmentSection = FragmentSection.COBROS
            target.success = success
            target.resultMsgTxt = resultMsgTxt
            target.summaryValues = summaryValues
            
            parentController?.onSectionChange(target: target,fragmentSection: FragmentSection.COBROS)
        }
    }
    
    private func parseToBpckObject() {
        bpckTxnDto = BillpocketTxnDto()
        bpckTxnDto?.accountType =  bpckParameters["accountType"]
        bpckTxnDto?.aid =  bpckParameters["aid"]
        bpckTxnDto?.amount =  bpckParameters["amount"]
        bpckTxnDto?.appError =  bpckParameters["appError"]
        bpckTxnDto?.applabel =  bpckParameters["applabel"]
        bpckTxnDto?.arqc =  bpckParameters["arqc"]
        bpckTxnDto?.authorizationNumber =  bpckParameters["authorization"]
        bpckTxnDto?.bank =  bpckParameters["bank"]
        bpckTxnDto?.captureMode =  bpckParameters["captureMode"]
        bpckTxnDto?.creditcard =  bpckParameters["creditcard"]
        bpckTxnDto?.cardtype =  bpckParameters["cardtype"]
        bpckTxnDto?.deviceToken =  bpckParameters["deviceToken"]
        bpckTxnDto?.email =  bpckParameters["email"]
        bpckTxnDto?.hidePrinter =  Bool.init(bpckParameters["hidePrinter"] ?? "false")
        bpckTxnDto?.identifier =  bpckParameters["identifier"]
        bpckTxnDto?.mandatoryPhoto =  Bool.init(bpckParameters["mandatoryPhoto"] ?? "false")
        bpckTxnDto?.msi =  bpckParameters["msi"]
        
        bpckTxnDto?.phone =  bpckParameters["phone"]
        bpckTxnDto?.reference =  bpckParameters["reference"]
        bpckTxnDto?.result =  bpckParameters["result"]
        bpckTxnDto?.skipMailPrint =  Bool.init(bpckParameters["skipMailPrint"] ?? "false")

        bpckTxnDto?.statusinfo =  bpckParameters["statusinfo"]
        bpckTxnDto?.thirdPartyId =  bpckParameters["thirdPartyId"]
        bpckTxnDto?.tip =  bpckParameters["tip"]
        bpckTxnDto?.transaction =  bpckParameters["transaction"]
        bpckTxnDto?.transactionId =  bpckParameters["transactionid"]
        
        bpckTxnDto?.url =  bpckParameters["url"]
        bpckTxnDto?.urlScheme =  bpckParameters["urlScheme"]
        bpckTxnDto?.userToken =  bpckParameters["userToken"]
        bpckTxnDto?.xpLandscape =  Bool.init(bpckParameters["xpLandscape"] ?? "false")
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
