//
//  RecargasViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 12/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import Alamofire

extension RecargasViewController {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField.tag > 1) {
            currentInputResponder = textField as? IconedUITextField
            return true
        }
        return false
        //return textField.tag > 1
    }
}

class RecargasViewController: SICobroViewController, ExtensionKeyboardActions {

    var observer : NSObjectProtocol?
    
    @IBOutlet weak var inputCompany: IconedUITextField!
    @IBOutlet weak var inputAmount: IconedUITextField!
    @IBOutlet weak var inputCell: IconedUITextField!
    @IBOutlet weak var inputConfirmCell: IconedUITextField!
    @IBOutlet weak var btnSubmit: CustomRoundedButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var taeProducts : [TaeProductDto] = []
    
    private var selectedCompanyIndex = 0
    private var selectedCompany : TaeProductDto? = nil
    private var selectedAmountIndex = 0
    private var selectedAmount = 0
    
    private let INPUT_SUBMIT_TAG = 3
        
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Looking for TAE Products")
        mobileSalesOpsService.getTaeProducts(callback: getTaeProductsCallback())
        
        self.inputCompany.rightImage = UIImage(named: "arrow_down")
        self.inputCompany.rightPadding = 10.0
        //self.inputCompany.addTarget(self, action: #selector(showCompaniesDialog), for: .touchDown)
        let tapcompany = UITapGestureRecognizer(target: self, action: #selector(showCompaniesDialog))
        self.inputCompany.addGestureRecognizer(tapcompany)
        self.inputCompany.isUserInteractionEnabled = true
        self.inputCompany.delegate = self
        
        self.inputAmount.rightImage = UIImage(named: "arrow_down")
        self.inputAmount.rightPadding = 10.0
        //self.inputAmount.addTarget(self, action: #selector(showAmountsDialog), for: .touchDown)
        let tapamount = UITapGestureRecognizer(target: self, action: #selector(showAmountsDialog))
        self.inputAmount.addGestureRecognizer(tapamount)
        self.inputAmount.isUserInteractionEnabled = true
        self.inputAmount.delegate = self
        
        self.inputCell.valueType = .phoneNumber
        self.inputCell.leftImage = UIImage(named: "mobile")
        self.inputConfirmCell.valueType = .phoneNumber
        self.inputConfirmCell.leftImage = UIImage(named: "mobile")
        
        self.inputCell.keyboardType = UIKeyboardType.numberPad
        self.inputConfirmCell.keyboardType = UIKeyboardType.numberPad
        
        self.inputCell.delegate = self
        self.inputConfirmCell.delegate = self
        self.indicator.isHidden = true
        
        self.keyboardActions = self
        let toolbar = self.getGenericFormToolbar(addNavButtons: true)
        self.inputCell.inputAccessoryView = toolbar
        self.inputConfirmCell.inputAccessoryView = toolbar
        
        self.btnSubmit.adjustFont(scale: 3.0)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let mobserver = observer {
            NotificationCenter.default.removeObserver(mobserver)
        }
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if let nextResponder = textField.superview?.viewWithTag(nextTag) {
            currentInputResponder = nextResponder as? IconedUITextField
            nextResponder.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    /**
    MARK: keyboard actions
     */
    func keybDoneButton() {
        if let responder = self.currentInputResponder {
            if responder.tag == INPUT_SUBMIT_TAG && self.btnSubmit.isEnabled {
                self.submitRecarga(self.btnSubmit)
            }
        }
    }
    
    func keybPrevButton(sender: UIBarButtonItem) {
        if let responder = self.currentInputResponder {
            let nextTag = responder.tag - 1
            if nextTag > 1 {
                if let nextResponder = responder.superview?.viewWithTag(nextTag) {
                    currentInputResponder = nextResponder as? IconedUITextField
                    nextResponder.becomeFirstResponder()
                    sender.isEnabled = nextTag <= 2
                }
                return
            }
            responder.resignFirstResponder()
        }
    }
    
    func keybNextButton(sender: UIBarButtonItem) {
        if let responder = self.currentInputResponder {
            let nextTag = responder.tag + 1
            if nextTag <= INPUT_SUBMIT_TAG {
                if let nextResponder = responder.superview?.viewWithTag(nextTag) {
                    currentInputResponder = nextResponder as? IconedUITextField
                    nextResponder.becomeFirstResponder()
                    sender.isEnabled = nextTag >= INPUT_SUBMIT_TAG
                }
                return
            }
            responder.resignFirstResponder()
        }
    }
    
    /*
    * Action from inputCompany View
    */
    @IBAction func showCompaniesDialog(_ sender: Any) {
        print("On showCompaniesDialog")
        if(taeProducts.isEmpty){
            showAlert(message: "No hay datos de compañias disponibles")
            return
        }
        
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = "Selecciona una opción"
        popup.popupArray = taeProducts.map({ (it) -> String in
            (it.name ?? "--")
        })
        popup.asRadioGroup = true
        popup.hideCloseButton = true
        popup.positiveButtonLabel = "Aceptar"
        popup.negativeButtonLabel = "Cancelar"
        popup.observerId = .saleTaeCompanies
        observer = NotificationCenter.default.addObserver(forName: .saleTaeCompanies, object: nil, queue: OperationQueue.main, using:
            { (notification) in
                // Action received from popup
                let itemIndexSelected = notification.object as! Int // Expect an integer fromn the list
                guard itemIndexSelected >= 0 else {
                    print("No data received from Chooser")
                    return
                }
                self.selectedCompanyIndex = itemIndexSelected
                
                self.refreshDropdownItems(index: itemIndexSelected)
                
                if let mobserver = self.observer {
                    NotificationCenter.default.removeObserver(mobserver)
                    self.observer = nil
                }
        })
        popup.controller = self
        self.present(popup, animated: true)
    }
    
    /*
    * Action from inputAmount View
    */
    @IBAction func showAmountsDialog(_ sender: Any) {
        print("On showCompaniesDialog")
        if(taeProducts.isEmpty){
            showAlert(message: "No hay datos de montos disponibles", tittle: "Recargas")
            return
        }
        
        guard let selectedCompany = selectedCompany else {
            showAlert(message: "No hay datos de montos disponibles", tittle: "Recargas")
            return
        }
        
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = "Selecciona una opción"
        
        guard let amounts = selectedCompany.amountList else {
            showAlert(message: "No hay montos disponibles")
            return
        }
        
        popup.popupArray = amounts.map({ (it) -> String in
            Utils.formatCurrency(number: Double(it))
        })
        popup.asRadioGroup = true
        popup.hideCloseButton = true
        popup.positiveButtonLabel = "Aceptar"
        popup.negativeButtonLabel = "Cancelar"
        popup.observerId = .saleTaeAmounts
        observer = NotificationCenter.default.addObserver(forName: .saleTaeAmounts, object: nil, queue: OperationQueue.main, using:
            { (notification) in
                // Action received from popup
                let itemIndexSelected = notification.object as! Int // Expect an integer fromn the list
                guard itemIndexSelected >= 0 else {
                    print("No data received from Chooser")
                    return
                }
                
                self.selectedAmountIndex = itemIndexSelected
                self.selectedAmount = selectedCompany.amountList![self.selectedAmountIndex]
                self.inputAmount.text = Utils.formatCurrency(number: Double(self.selectedAmount))
                
                if let mobserver = self.observer {
                    NotificationCenter.default.removeObserver(mobserver)
                    self.observer = nil
                }
        })
        popup.controller = self
        self.present(popup, animated: true)
    }
    
    @IBAction func onFormEnds(_ sender: Any) {
        //validate()
    }
    
    @IBAction func submitRecarga(_ sender: UIButton) {
        if(!self.validateSessions(forwardToInitial: false, destroyCurrentView: true)) {
            return
        }
        validate()
    }
    
    private func validate() {
        guard let inputCompanyStr = inputCompany.text, !inputCompanyStr.isEmpty else {
            showAlert(message: "El campo Compañia es requerido", tittle: "Recargas")
            return
        }
        
        guard let inputAmountStr = inputAmount.text, !inputAmountStr.isEmpty else {
            showAlert(message: "El campo Monto es requerido", tittle: "Recargas")
            return
        }
        
        guard let inputCellStr = inputCell.text, !inputCellStr.isEmpty else {
            showAlert(message: "El campo Número Celular es requerido", tittle: "Recargas")
            return
        }
        
        guard let inputConfirmCellStr = inputConfirmCell.text, !inputConfirmCellStr.isEmpty else {
            showAlert(message: "El campo Confirmar Número Celular es requerido", tittle: "Recargas")
            return
        }
        
        guard inputCellStr == inputConfirmCellStr else {
            showAlert(message: "Los teléfonos no coinciden", tittle: "Recargas")
            return
        }
        //pbRecarga.visibility = View.VISIBLE

        /*
        var recargaType = RecargaType()
        recargaType.phone = inputCellStr
        recargaType.amount = selectedAmount
         */

        var taeSaleRequest = TaeSaleRequest()
        taeSaleRequest.phone = inputCellStr
        taeSaleRequest.amountCents = (selectedAmount * 100)
        taeSaleRequest.productTxnId = taeProducts[selectedCompanyIndex].txnId

        changeViewsEnable(enabled: false)
        mobileSalesOpsService.performSaleTaeOperation(request: taeSaleRequest, callback: getSubmitTaeOperationCallback())
        
        // TESTING
        //var summaryValues:[SummaryItem] = []
        //summaryValues.append(SummaryItem(name: "Tipo de error",value: "500" ))
        //summaryValues.append(SummaryItem(name: "Tipo de error",value: "500" ))
        //summaryValues.append(SummaryItem(name: "Tipo de error",value: "500" ))
        //summaryValues.append(SummaryItem(name: "Mensaje de error",value: "JSON could not be serialized because of error:\nThe data couldn’t be read because it isn’t in the correct format"))
        
        //self.sendSummary(success: true, resultMsgTxt: "¡Ups, algo sucedio!", summaryValues: summaryValues)
           
    }
        
    private func getSubmitTaeOperationCallback() -> RestCallback<TaeSaleResponse> {
        let saleOnResponse : ((TaeSaleResponse?) -> ())? = { response in
            self.changeViewsEnable(enabled: true)
            print("response \(String(describing: response))")
            
            var productName : TaeSaleResponse = response!
            var summaryValues:[SummaryItem] = []
            summaryValues.append(SummaryItem(name: "Compañia",value: productName.productName ?? "---"))
            summaryValues.append(SummaryItem(name: "Teléfono",value: productName.phone ?? "---"))
            summaryValues.append(SummaryItem(name: "Monto",value: Utils.formatCurrency(number: Double(self.selectedAmount))))
            summaryValues.append(SummaryItem(name: "Folio",value: productName.approvalCode ?? "---"))
            self.sendSummary(success: true, resultMsgTxt: "¡Tu recarga está lista!", summaryValues: summaryValues)
        }
        
        let saleApiError : ((ApiError)->())? =  { apiError in
            self.changeViewsEnable(enabled: true)
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
            
            var summaryValues:[SummaryItem] = []
            summaryValues.append(SummaryItem(name: "Tipo de error",value: msg ?? "Desconocido"))
            summaryValues.append(SummaryItem(name: "Mensaje de error",value: code ?? "N/A"))
            self.sendSummary(success: false, resultMsgTxt: "¡Ups, algo sucedio!", summaryValues: summaryValues)
        }
        
        let saleOnFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            self.changeViewsEnable(enabled: true)
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            print("debugDescription \(String(describing: response?.debugDescription))")
            
            var summaryValues:[SummaryItem] = []
            summaryValues.append(SummaryItem(name: "Tipo de error",value: "\(response?.statusCode ?? -1)" ))
            summaryValues.append(SummaryItem(name: "Mensaje de error",value: error?.errorDescription ?? "N/A"))
            self.sendSummary(success: false, resultMsgTxt: "¡Ups, algo sucedio!", summaryValues: summaryValues)
            //self.showAlert(message: "Ocurrio un error invocando el servicio. Verifique su conexion de red.")
        }
        
        return RestCallback<TaeSaleResponse>(onResponse: saleOnResponse, onApiError: saleApiError, onFailure: saleOnFailure)
    }
    
    private func getTaeProductsCallback() -> RestCallback<[TaeProductDto]> {
        let saleOnResponse : (([TaeProductDto]?) -> ())? = { response in
            self.changeViewsEnable(enabled: true)
            print("response \(String(describing: response))")
            
            if(response != nil) {
                self.taeProducts.removeAll()
                self.taeProducts.append(contentsOf: response ?? [])
                self.refreshDropdownItems(index: 0)
            }
        }
        
        let saleApiError : ((ApiError)->())? =  { apiError in
            self.changeViewsEnable(enabled: true)
            let smsg = "Ocurrio un error en en la recarga"
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
        }
        
        let saleOnFailure = genericOnFailure
        
        return RestCallback<[TaeProductDto]>(onResponse: saleOnResponse, onApiError: saleApiError, onFailure: saleOnFailure)
    }
    
    
    private func refreshDropdownItems(index:Int) {
        if (!taeProducts.isEmpty) {
            selectedCompanyIndex = index
            selectedCompany = taeProducts[index]
            inputCompany.text = selectedCompany?.name
            
            // Select first elements of the amounts
            if let isEmpty = selectedCompany?.amountList?.isEmpty {
                debugPrint("selectedCompany?.amountList?.isEmpty: \(isEmpty)")
                if (!isEmpty) {
                    selectedAmountIndex = 0
                    if let amount = selectedCompany?.amountList?[selectedAmountIndex] {
                        debugPrint("First amount: \(amount)")
                        selectedAmount = amount
                        inputAmount.text = Utils.formatCurrency(number: Double(selectedAmount))
                    }
                    //selectedAmount = selectedCompany?.amountList?[selectedAmountIndex]
                }
            }
        }
        
        //inputCompany.setText("---")
        //inputAmount.setText("---")
    }
    
    private func changeViewsEnable(enabled: Bool) {
        inputCompany.isEnabled = enabled
        inputAmount.isEnabled = enabled
        inputCell.isEnabled = enabled
        inputConfirmCell.isEnabled = enabled
        btnSubmit.isEnabled = enabled
        if(enabled) {
            btnSubmit.isEnabled = true
            btnSubmit.isHidden = false
            self.indicator.stopAnimating()
        } else {
            btnSubmit.isEnabled = false
            btnSubmit.isHidden = true
            self.indicator.isHidden = false
            self.indicator.startAnimating()
        }
    }
    
    private func sendSummary(success: Bool, resultMsgTxt: String, summaryValues: [SummaryItem]) {
        if(parentController != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let target = storyboard.instantiateViewController(withIdentifier: "abstractResultVC") as! AbstractResultViewController
            
            target.resultTitleTxt = "Recarga de Tiempo Aire"
            target.repeatButtonTxt = "Realizar otra recarga"
            target.fragmentSection = FragmentSection.RECARGAS
            //target.targetAction = FragmentSection.RECARGAS.rawValue
            target.success = success
            target.resultMsgTxt = resultMsgTxt
            target.summaryValues = summaryValues
            
            parentController?.onSectionChange(target: target, fragmentSection: FragmentSection.RECARGAS)
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

extension Notification.Name {
    static let saleTaeCompanies = Notification.Name(rawValue: "saleTaeCompaniesCaller")
    static let saleTaeAmounts = Notification.Name(rawValue: "saleTaeAmountsCaller")
    static let productPicker = Notification.Name(rawValue: "productPickerCaller")
    
    static let datePicker = Notification.Name(rawValue: "datePickerCaller")
}
