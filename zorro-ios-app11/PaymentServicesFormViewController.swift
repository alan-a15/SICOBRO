//
//  PaymentServicesFormViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 19/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

extension PaymentServicesFormViewController {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //return !(textField.tag == 0 || (textField.tag == 2 && selectedProduct?.fixedAmountsEnabled ?? false))
        //return false
        if(textField.tag >= 1) {
            if(textField.tag == 2) {
                if let selectedProduct = self.selectedProduct {
                    if( selectedProduct.fixedAmountsEnabled != nil && selectedProduct.fixedAmountsEnabled! ) {
                        return false
                    }
                }
            }
            currentInputResponder = textField as? IconedUITextField
            return true;
        }
        return false
    }
}

class PaymentServicesFormViewController: SICobroViewController, ExtensionKeyboardActions {

    var observer : NSObjectProtocol?
    
    @IBOutlet weak var inputSrvName: IconedUITextField!
    
    @IBOutlet weak var srvIcon: UIImageView!
    
    @IBOutlet weak var srvName: UILabel!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var inputSrvReference: IconedUITextField!
    
    @IBOutlet weak var inputSrvAmount: IconedUITextField!
    
    @IBOutlet weak var inputSrvComision: IconedUITextField!
    
    @IBOutlet weak var inputSrvAmountToPay: IconedUITextField!
    
    @IBOutlet weak var inputSrvBDecrease: IconedUITextField!
    
    @IBOutlet weak var submitBtn: CustomRoundedButton!
    
    @IBOutlet weak var iconReference: UIImageView!
    
    private var selectedAmountIndex = 0
    private var selectedAmount = 0

    private var selectedProductIndex = 0
    private var selectedProduct:ProductObj?
    
    var srvSegmentType: ServiceSegment?
    private var products : [ProductDto]?
    
    private var prepareTxnRequest : PrepareTxnRequest?

    private var prepareTxnResponse : PrepareTxnResponse?
    
    private var transactionResponseObj : TransactionResponseObj?
    
    private let INPUT_SUBMIT_TAG = 2

    //private var productObj: ProductObj? = null
    
    @IBOutlet weak var labelDecrease: UILabel!
    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelComission: UILabel!
    @IBOutlet weak var labelAmountToPay: UILabel!
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        guard let srvSegmentType = srvSegmentType else {
            self.showAlert(message: "No hay servicio seleccionado. Por favor regrese al menu de Servicios.")
            return
        }
        
        self.srvName.text = srvSegmentType.name
        self.srvIcon.image = UIImage(named: srvSegmentType.icon)
        //self.srvName.font = UIFont.systemFont(ofSize: 26.0)
    
        submitBtn.titleLabel!.numberOfLines = 1
        //submitBtn.titleLabel!.adjustsFontSizeToFitWidth = true
        //submitBtn.titleLabel!.lineBreakMode = .byClipping
        submitBtn.titleLabel?.baselineAdjustment = .alignCenters
        submitBtn.titleLabel?.translatesAutoresizingMaskIntoConstraints = true
        submitBtn.titleLabel?.sizeToFit()
        
        inputSrvName.cornerRadius = 10.0
        inputSrvName.borderColor = UIColor(named: "colorPrimary")
        inputSrvName.rightPadding = 15.0
        inputSrvName.delegate = self
        inputSrvName.setValue(UIColor(named: "colorPrimary")?.withAlphaComponent(0.5),
                              forKeyPath: "placeholderLabel.textColor")
        
        inputSrvReference.cornerRadius = 10.0
        inputSrvReference.borderColor = UIColor(named: "colorPrimary")
        inputSrvReference.rightImage = nil
        inputSrvReference.clearButtonMode = .never
        inputSrvReference.maxLength = 20
        inputSrvReference.delegate = self
        inputSrvReference.returnKeyType = UIReturnKeyType.next
        inputSrvReference.setValue(UIColor(named: "colorPrimary")?.withAlphaComponent(0.5),
        forKeyPath: "placeholderLabel.textColor")
        inputSrvReference.addTarget(self, action: #selector(self.referencesChanged), for: UIControl.Event.editingChanged)
        
        inputSrvAmount.text = ""
        inputSrvAmount.cornerRadius = 10.0
        inputSrvAmount.borderWidth = 2.0
        inputSrvAmount.borderColor = UIColor(named: "colorPrimary")
        inputSrvAmount.leftImage = UIImage(named: "amountg")
        inputSrvAmount.sizeToFit()
        inputSrvAmount.placeholder = "0.00"
        inputSrvAmount.maxLength = 10
        inputSrvAmount.valueType = .currency
        inputSrvAmount.delegate = self
        inputSrvAmount.setValue(UIColor(named: "colorPrimary")?.withAlphaComponent(0.5),
        forKeyPath: "placeholderLabel.textColor")
        inputSrvAmount.keyboardType = .decimalPad
        inputSrvAmount.addTarget(self, action: #selector(self.amountChanged), for: UIControl.Event.editingChanged)
        
        inputSrvComision.isEnabled = false
        inputSrvComision.text = ""
        inputSrvComision.cornerRadius = 10.0
        inputSrvComision.borderColor = UIColor(named: "nonSelectedText")
        inputSrvComision.leftImage = UIImage(named: "amountg")
        inputSrvComision.rightImage = nil
        inputSrvComision.sizeToFit()
        inputSrvComision.placeholder = "0.00"
        inputSrvComision.setValue(UIColor(named: "colorPrimary")?.withAlphaComponent(0.5),
        forKeyPath: "placeholderLabel.textColor")
        
        inputSrvAmountToPay.isEnabled = false
        inputSrvAmountToPay.text = ""
        inputSrvAmountToPay.cornerRadius = 10.0
        inputSrvAmountToPay.borderColor = UIColor(named: "nonSelectedText")
        inputSrvAmountToPay.leftImage = UIImage(named: "amountg")
        inputSrvAmountToPay.rightImage = nil
        inputSrvAmountToPay.sizeToFit()
        //inputSrvAmountToPay.font = UIFont.systemFont(ofSize: 22.0)
        inputSrvAmountToPay.placeholder = "0.00"
        inputSrvAmountToPay.setValue(UIColor(named: "colorPrimary")?.withAlphaComponent(0.5),
        forKeyPath: "placeholderLabel.textColor")
        
        inputSrvBDecrease.isEnabled = false
        inputSrvBDecrease.text = ""
        inputSrvBDecrease.cornerRadius = 10.0
        inputSrvBDecrease.borderColor = UIColor(named: "nonSelectedText")
        inputSrvBDecrease.leftImage = UIImage(named: "amountg")
        inputSrvBDecrease.rightImage = nil
        inputSrvBDecrease.sizeToFit()
        //inputSrvBDecrease.delegate = self
        //inputSrvBDecrease.font = UIFont.systemFont(ofSize: 22.0)
        inputSrvBDecrease.placeholder = "0.00"
        inputSrvBDecrease.setValue(UIColor(named: "colorPrimary")?.withAlphaComponent(0.5),
        forKeyPath: "placeholderLabel.textColor")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openReference))
        iconReference.addGestureRecognizer(tap)
        iconReference.isUserInteractionEnabled = true
        
        self.keyboardActions = self
        let toolbar = self.getGenericFormToolbar()
        self.inputSrvName.isUserInteractionEnabled = true
        self.inputSrvReference.inputAccessoryView = toolbar
        self.inputSrvAmount.inputAccessoryView = toolbar
        
        //self.inputSrvName.addTarget(self, action: #selector(showProducts), for: .touchDown)
        let tapSrv = UITapGestureRecognizer(target: self, action: #selector(showProducts))
        inputSrvName.addGestureRecognizer(tapSrv)
        inputSrvName.isUserInteractionEnabled = true
        
        onTransactionPrepared()
        
        servicesPaymentService.getProducts(segmentId: srvSegmentType.id, callback: getProductsCallback())
        
        self.inputSrvName.adjustFont()
        self.inputSrvReference.adjustFont()
        self.inputSrvAmount.adjustFont()
        self.inputSrvComision.adjustFont()
        self.inputSrvAmountToPay.adjustFont()
        self.inputSrvBDecrease.adjustFont()
        //self.submitBtn.adjustFont()
        
        // Update labels font size based on the smaller one
        //let smallerFont = labelDecrease.font
    
    /*
        // Get the size of the text with no scaling (one line)
        let sizeOneLine: CGSize = labelDecrease.text!.size(withAttributes: [NSAttributedString.Key.font: labelDecrease.font])
        // Get the size of the text enforcing the scaling based on label width
        let sizeOneLineConstrained: CGSize = labelDecrease.text!.boundingRect(with: labelDecrease.frame.size, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: labelDecrease.font], context: nil).size
        // Approximate scaling factor
        let approxScaleFactor: CGFloat = sizeOneLineConstrained.width / sizeOneLine.width
        // Approximate new point size
        let approxScaledPointSize: CGFloat = approxScaleFactor * labelDecrease.font.pointSize
 */
        
        var currentFont: UIFont = labelDecrease.font
        let originalFontSize = currentFont.pointSize
        var currentSize: CGSize = (labelDecrease.text! as NSString).size(withAttributes: [NSAttributedString.Key.font: currentFont])

        while currentSize.width > labelDecrease.frame.size.width && currentFont.pointSize > (originalFontSize * labelDecrease.minimumScaleFactor) {
            currentFont = currentFont.withSize(currentFont.pointSize - 1)
            currentSize = (labelDecrease.text! as NSString).size(withAttributes: [NSAttributedString.Key.font: currentFont])
        }
        
        labelAmount.font = currentFont
        labelComission.font = currentFont
        labelAmountToPay.font = currentFont
        labelDecrease.font = currentFont
        
        self.submitBtn.adjustFont(scale: 3.0)
    }
    
    override func viewDidLayoutSubviews() {
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let nextTag = textField.tag + 1
        if nextTag == 2 && !(selectedProduct?.fixedAmountsEnabled ?? false) {
            currentInputResponder = inputSrvAmount
            inputSrvAmount.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    /**
    MARK: keyboard actions
     */
    func keybDoneButton() {
        debugPrint("Responder: \(String(describing: currentInputResponder))")
        if let responder = currentInputResponder {
            debugPrint("Responder Tag: \(String(describing: responder.tag))")
            if responder.tag == INPUT_SUBMIT_TAG && self.submitBtn.isEnabled {
                self.submitPayment(self.submitBtn)
            }
        }
    }
    
    func keybPrevButton(sender: UIBarButtonItem) { }
    
    func keybNextButton(sender: UIBarButtonItem) { }
    
    @objc func amountChanged(_ textField: UITextField) {
        if self.selectedProduct != nil {
            if (isTransactionPrepared()) {
                var inputSrvAmountStr = inputSrvAmount.text
                inputSrvAmountStr = inputSrvAmountStr?.replacingOccurrences(of: "$", with: "")
                if let prepareTxnResponse = self.prepareTxnResponse {
                    if (inputSrvAmountStr != prepareTxnResponse.amount) {
                        self.prepareTxnResponse = nil
                        onTransactionPrepared()
                        //self.showAlert(message: "El importe ha cambiado")
                    }
                }
            }
        }
    }
    
    @objc func referencesChanged(_ textField: UITextField) {
        if self.selectedProduct != nil {
            if (isTransactionPrepared()) {
                let inputSrvReferenceStr = inputSrvReference.text
                if let prepareTxnRequest = self.prepareTxnRequest {
                    if (inputSrvReferenceStr != prepareTxnRequest.paymentReference) {
                        self.prepareTxnResponse = nil
                        onTransactionPrepared()
                        //self.showAlert(message: "La referencia ha cambiado")
                    }
                }
            }
        }
    }
    
    @IBAction func showProducts(_ sender: Any) {
        debugPrint("On showProducts")
        if let products:[ProductDto] = products, products.isEmpty {
            showAlert(message: "No hay datos de productos del segemento actual")
            return
        }
        
        self.view.endEditing(true)
        
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = "Selecciona una opción"
        popup.customTitleColor = UIColor(named: "helperColor")!
        popup.popupArray = (products?.map({ (dto) -> String in
            dto.name ?? "--"
        }))!
        popup.selectedIndex = self.selectedProductIndex
        popup.positiveButtonLabel = "Aceptar"
        popup.negativeButtonLabel = "Cancelar"
        popup.asRadioGroup = true
        popup.hideCloseButton = true
        popup.observerId = .productPicker
        observer = NotificationCenter.default.addObserver(forName: .productPicker, object: nil, queue: OperationQueue.main, using:
            { (notification) in
                // Action received from popup
                let itemIndexSelected = notification.object as! Int // Expect an integer fromn the list
                guard itemIndexSelected >= 0 else {
                    if let mobserver = self.observer {
                        NotificationCenter.default.removeObserver(mobserver)
                        self.observer = nil
                    }
                    
                    print("No data received from Chooser")
                    return
                }
                
                self.selectedProductIndex = itemIndexSelected
                self.selectedProduct = ProductObj.fromProduct(sproduct: self.products?[self.selectedProductIndex])
                self.onProductSelected()
                
                if let mobserver = self.observer {
                    NotificationCenter.default.removeObserver(mobserver)
                    self.observer = nil
                }
        })
        popup.controller = self
        self.present(popup, animated: true)
        
    }
    
    
    @IBAction func showAmounts(_ sender: Any) {
        if let selectedProduct = self.selectedProduct {
            if( selectedProduct.fixedAmountsEnabled ?? false ) {
                debugPrint("On showAmounts")
                guard let _ = selectedProduct.fixedAmounts, !selectedProduct.lstFixedAmount.isEmpty else {
                    self.showAlert(message: "No hay datos de montos fijos disponibles")
                    return
                }
                
                let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
                let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
                popup.customTitle = "Selecciona una opción"
                popup.customTitleColor = UIColor(named: "helperColor")!
                popup.popupArray = selectedProduct.lstFixedAmount.map({ (v) -> String in
                    Utils.formatCurrency(number: Double(v))
                })
                popup.selectedIndex = self.selectedAmountIndex
                popup.asRadioGroup = true
                popup.hideCloseButton = true
                popup.positiveButtonLabel = "Aceptar"
                popup.negativeButtonLabel = "Cancelar"
                popup.observerId = .productPicker
                observer = NotificationCenter.default.addObserver(forName: .productPicker, object: nil, queue: OperationQueue.main, using:
                    { (notification) in
                        // Action received from popup
                        let itemIndexSelected = notification.object as! Int // Expect an integer fromn the list
                        guard itemIndexSelected >= 0 else {
                            if let mobserver = self.observer {
                                NotificationCenter.default.removeObserver(mobserver)
                                self.observer = nil
                            }
                            
                            print("No data received from Chooser")
                            return
                        }
                        
                        self.selectedAmountIndex = itemIndexSelected
                        self.selectedAmount = selectedProduct.lstFixedAmount[self.selectedAmountIndex]
                        self.inputSrvAmount.text = "\( Utils.formatDecimal( number: Double(self.selectedAmount) ))"
                        
                        if let mobserver = self.observer {
                            NotificationCenter.default.removeObserver(mobserver)
                            self.observer = nil
                        }
                        
                        self.amountChanged(self.inputSrvAmount)
                        if self.submitBtn.isEnabled {
                            self.submitPayment(self.submitBtn)
                        }
                })
                popup.controller = self
                self.present(popup, animated: true)
            }
        }
    }
    
    @objc func openReference() {
        debugPrint("On openReference")
        if let selectedProduct = self.selectedProduct {
            if let referenceImage = selectedProduct.referenceImage {
                if(!referenceImage.lowercased().hasSuffix("null") && referenceImage.lowercased().hasSuffix("png")) {
                    let escapedreferenceImage = referenceImage.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                    if escapedreferenceImage != nil {
                        openReferenceImage(url:referenceImage)
                    }
                    return
                }
            }
            openReferenceHelp(product: selectedProduct)
            return
        }
        self.showAlert(message: "Servicio no seleccionado.")
    }
    
    private func openReferenceImage(url:String) {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        if let selectedProduct = self.selectedProduct {
            popup.customTitle = selectedProduct.name ?? "Referencia"
        } else {
            popup.customTitle = "Referencia"
        }
        popup.customTitleColor = UIColor(named: "helperColor")!
        
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        
        //let webView:WKWebView = WKWebView(frame: , configuration: wkWebConfig)
        //webView.load(NSURLRequest(url: NSURL(string: url)! as URL) as URLRequest)
        //webView.contentMode = .scaleAspectFit
        //webView.delegate = self
        //popup.setWebViewObj(wv: webView)
        
        popup.setWebUrl(surl: url)
        popup.wkWebConfig = wkWebConfig
        popup.contentMode = .scaleAspectFit
        
        popup.fixedHeightSizePer = 0.25
        
        self.present(popup, animated: true)
    }
    
    private func openReferenceHelp(product:ProductDto) {
        let storyboard = UIStoryboard(name: "CustomPopup" , bundle: nil)
        
        let popup = storyboard.instantiateInitialViewController() as! CustomPopUpViewController
        popup.customTitle = product.name ?? "Referencia"
        popup.customTitleColor = UIColor(named: "helperColor")!
        
        let textlbl = UILabel()
        textlbl.textColor = UIColor(named: "colorPrimaryDark")
        textlbl.font = UIFont.systemFont(ofSize: 18)
        textlbl.textAlignment = .left
        textlbl.numberOfLines = 10
        
        var msg = ""
        if let referenceSizeDescription = product.referenceSizeDescription, !referenceSizeDescription.isEmpty {
            msg = "\t\(referenceSizeDescription)"
        }
        if let referenceDescription = product.referenceDescription, !referenceDescription.isEmpty {
            if(!msg.isEmpty) {
                msg += "\n"
            }
            msg = "\t\(referenceDescription)"
        }
        
        textlbl.text = (!msg.isEmpty) ? "Referencia:\n\(msg)" : "No hay datos de ayuda sobre la referencia para \(product.name ?? "--")"
        
        popup.fixedHeightSizePer = 0.25
        popup.content = textlbl
        
        self.present(popup, animated: true)
    }
    
    @IBAction func submitPayment(_ sender: CustomRoundedButton) {
        if(!self.validateSessions(forwardToInitial: false, destroyCurrentView: true)) {
            return
        }
        
        if self.selectedProduct != nil {
            /*
            val view = activity!!.currentFocus
            if (view != null) {
                val imm =
                    activity!!.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                imm.hideSoftInputFromWindow(view.windowToken, 0)
            }
             */
            
            isTransactionPrepared() ? validateForApplyTxn()
                                    : validateForPrepareTxn()
        } else {
            self.showAlert(message: "Servicio no seleccionado.")
        }
    }
    
    private func onProductSelected() {
        self.inputSrvName.text = self.selectedProduct?.name
        
        // Reset transaction in this case as well.
        self.prepareTxnResponse = nil
        self.onTransactionPrepared()
        
        if let selectedProduct = self.selectedProduct {
            if( selectedProduct.fixedAmountsEnabled ?? false ) {
                // Set ComboBox enabled
                inputSrvAmount.isEnabled = true
                inputSrvAmount.updateFocusIfNeeded()
                inputSrvAmount.rightImage = UIImage(named: "arrow_down_2")
                
                // Setting 1st one by default
                self.selectedAmountIndex = 0
                self.selectedAmount = selectedProduct.lstFixedAmount[self.selectedAmountIndex]
                self.inputSrvAmount.text = "\( Utils.formatDecimal( number: Double(self.selectedAmount) ))" // "\(Double(self.selectedAmount))"

                //inputSrvReference!!.imeOptions = EditorInfo.IME_ACTION_DONE
                //inputSrvAmount!!.requestLayout()
            } else {
                // Set Regular Input
                inputSrvAmount.isEnabled = true
                if( inputSrvAmount.rightImage != nil ) {
                    inputSrvAmount.updateFocusIfNeeded()
                    inputSrvAmount.rightImage = nil
                    //inputSrvAmount.leftImage = UIImage(named: "")
                }
            }
        }
    }
    
    private func onTransactionPrepared() {
        setContainerBackground(container: inputSrvComision)
        setContainerBackground(container: inputSrvAmountToPay)
        setContainerBackground(container: inputSrvBDecrease)

        if(isTransactionPrepared()) {
            if let prepareTxnResponse = self.prepareTxnResponse {
                inputSrvComision.text = prepareTxnResponse.commission ?? "0.00"
                inputSrvAmountToPay.text = prepareTxnResponse.totalAmount ?? "0.00"
                inputSrvBDecrease.text = prepareTxnResponse.balanceDecrease ?? "0.00"
            }
        } else {
            inputSrvComision.text = "0.00"
            inputSrvAmountToPay.text = "0.00"
            inputSrvBDecrease.text = "0.00"
        }
    }
    
    private func isTransactionPrepared() -> Bool {
        return prepareTxnResponse != nil
    }
    
    private func validateForPrepareTxn() {
        guard let inputSrvAmountStr = inputSrvAmount.text, !inputSrvAmountStr.isEmpty else {
            self.showAlert(message: "El campo Importe es requerido")
            return
        }
        
        guard let inputSrvReferenceStr = inputSrvReference.text, !inputSrvReferenceStr.isEmpty else {
            self.showAlert(message: "El campo Referencia es requerido")
            return
        }

        inputSrvName.isEnabled = false
        inputSrvReference.isEnabled = false
        inputSrvAmount.isEnabled = false
        submitBtn.isEnabled = false
        submitBtn.isHidden = true
        indicator.isHidden = false
        indicator.startAnimating()

        // Preparing Request
        prepareTxnRequest = PrepareTxnRequest()
        prepareTxnRequest?.amountDecimal = inputSrvAmountStr.replacingOccurrences(of: "$", with: "")
        prepareTxnRequest?.clientUUID = UUID.init().uuidString
        prepareTxnRequest?.paymentReference = inputSrvReferenceStr
        prepareTxnRequest?.productTxnId = selectedProduct?.txnId

        // It should secure to unwrap forcebely because we have already defined this object some lines above
        servicesPaymentService.prepareTransaction(request: prepareTxnRequest!, callback: getPrepareTransactionCallback())
        
    }
    
    private func validateForApplyTxn() {
        // TO-DO Validate if reference and/or amount has changed

        if let prepareTxnResponse = self.prepareTxnResponse {
            inputSrvName.isEnabled = false
            inputSrvReference.isEnabled = false
            inputSrvAmount.isEnabled = false
            submitBtn.isEnabled = false
            submitBtn.isHidden = true
            indicator.isHidden = false
            indicator.startAnimating()
            
            var transactionRequest = TransactionRequest()
            transactionRequest.janoUUID = prepareTxnResponse.janoUUID
            transactionRequest.amountDecimal = prepareTxnResponse.amount
            
            if let prepareTxnRequest = self.prepareTxnRequest {
                transactionRequest.productTxnId = prepareTxnRequest.productTxnId
                transactionRequest.paymentReference = prepareTxnRequest.paymentReference
                transactionRequest.clientUUID = prepareTxnRequest.clientUUID
            } else{
                // Unexpected case
                self.showAlert(message: "La transacción no estaba preparada aún.")
                return
            }

            servicesPaymentService.applyTransaction(request: transactionRequest, callback: getApplyTransactionCallback())
            
            // TESTING
            /*
            var summaryValues:[SummaryItem] = []
            summaryValues.append(SummaryItem(name: "Tipo de error",value: "500" ))
            summaryValues.append(SummaryItem(name: "Tipo de error",value: "500" ))
            summaryValues.append(SummaryItem(name: "Tipo de error",value: "500" ))
            summaryValues.append(SummaryItem(name: "Mensaje de error",value: "JSON could not be serialized because of error:\nThe data couldn’t be read because it isn’t in the correct format"))
            
            self.sendSummary(success: true, resultMsgTxt: "¡Ups, algo sucedio!", summaryValues: summaryValues, delegate: self)
             */
            
            return
        }
        // Unexpected case
    }
    
    private func setContainerBackground(container : IconedUITextField) {
        container.borderWidth = 2
        container.borderColor = !isTransactionPrepared() ? UIColor(named: "nonSelectedText")
                                                         : UIColor(named: "colorPrimary")
    }
    
    // MARK: Callbacks
    private func getProductsCallback() -> RestCallback<[ProductDto]> {
        let onResponse : (([ProductDto]?) -> ())? = { response in
            self.indicator.stopAnimating()
            debugPrint("response \(String(describing: response))")
            
            ////////////////////////////////////////////////////////////////////////////////
            self.products = response
            ////////////////////////////////////////////////////////////////////////////////
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let smsg = "Error obteniendo Productos de segmento - Message "
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            self.showAlert(message: "Ocurrio un error invocando el servicio. Verifique su conexión a internet. - \(String(describing: error?.errorDescription))")
        }
        return RestCallback<[ProductDto]>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    private func getPrepareTransactionCallback() -> RestCallback<PrepareTxnResponse> {
        let onResponse : ((PrepareTxnResponse?) -> ())? = { response in
            self.indicator.stopAnimating()
            debugPrint("response \(String(describing: response))")
            
            self.inputSrvName.isEnabled = true
            self.inputSrvReference.isEnabled = true
            self.inputSrvAmount.isEnabled = true
            self.submitBtn.isEnabled = true
            self.submitBtn.isHidden = false
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            
            ////////////////////////////////////////////////////////////////////////////////
            self.prepareTxnResponse = response
            self.onTransactionPrepared()
            //self.showAlert(message: "Transaccion preparada. Verifique los datos")
            ////////////////////////////////////////////////////////////////////////////////
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            let smsg = "Ocurrio un error obteniendo Preparando la transaccion - Message "
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.inputSrvName.isEnabled = true
            self.inputSrvReference.isEnabled = true
            self.inputSrvAmount.isEnabled = true
            self.submitBtn.isEnabled = true
            self.submitBtn.isHidden = false
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.showAlert(message: "\(smsg): \(msg)")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            
            self.inputSrvName.isEnabled = true
            self.inputSrvReference.isEnabled = true
            self.inputSrvAmount.isEnabled = true
            self.submitBtn.isEnabled = true
            self.submitBtn.isHidden = false
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            self.showAlert(message: "Ocurrio un error invocando el servicio. Verifique su conexión a internet. - \(String(describing: error?.errorDescription))")
        }
        return RestCallback<PrepareTxnResponse>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    private func getApplyTransactionCallback() -> RestCallback<TransactionResponse> {
        let onResponse : ((TransactionResponse?) -> ())? = { response in
            self.indicator.stopAnimating()
            debugPrint("transactionResponse \(String(describing: response))")
            
            self.inputSrvName.isEnabled = true
            self.inputSrvReference.isEnabled = true
            self.inputSrvAmount.isEnabled = true
            self.submitBtn.isEnabled = true
            self.submitBtn.isHidden = false
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            
            //transactionResultObj!!.success = true
            ////////////////////////////////////////////////////////////////////////////////
            if let transactionResponse = response {
                self.transactionResponseObj = TransactionResponseObj()
                self.transactionResponseObj?.fromTransactionResponse(transactionResponse: transactionResponse)
                
                if let prepareTxnRequest = self.prepareTxnRequest {
                    self.transactionResponseObj?.clientUUID = prepareTxnRequest.clientUUID ?? ""
                } else {
                    self.showAlert(message: "La transaccion no fue preparada correctamente.")
                    return
                }
                
                if let prepareTxnResponse = self.prepareTxnResponse {
                    self.transactionResponseObj?.janoUUID = prepareTxnResponse.janoUUID ?? ""
                } else {
                    self.showAlert(message: "La transaccion no fue preparada correctamente.")
                    return
                }
                
                // Invoke result page HERE.
                var summaryValues:[SummaryItem] = []
                if let transactionResponseObj = self.transactionResponseObj {
                    summaryValues.append(SummaryItem(name: "Código de aprobación",value: transactionResponseObj.approvalCode ?? "-"))
                    summaryValues.append(SummaryItem(name: "Producto",value: transactionResponseObj.productName ?? "-" ))
                    summaryValues.append(SummaryItem(name: "Monto",value: transactionResponseObj.totalAmount ?? "-" ))
                    summaryValues.append(SummaryItem(name: "Referencia",value: transactionResponseObj.paymentReference ?? "-"))
                }
                self.sendSummary(success: true, resultMsgTxt: "¡Tu pago ha sido aplicado!", summaryValues: summaryValues, addDelegate: true)
                
            } else {
                self.showAlert(message: "No se obtuvo respuesta de la transacción")
                return
            }
            ////////////////////////////////////////////////////////////////////////////////
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            self.inputSrvName.isEnabled = true
            self.inputSrvReference.isEnabled = true
            self.inputSrvAmount.isEnabled = true
            self.submitBtn.isEnabled = true
            self.submitBtn.isHidden = false
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            
            let smsg = "Ocurrio un error obteniendo Aplicando la transacción - Message "
            debugPrint("\(smsg): \(apiError.message ?? "-")")
            //self.showAlert(message: "\(smsg): \(msg)")
            
            self.transactionResponseObj = TransactionResponseObj()
            if(apiError.apiErrorType == ApiError.ApiErrorType.authorizer) {
                self.transactionResponseObj?.msgError = apiError.authorizerResponseMessage ?? "Desconocido"
                self.transactionResponseObj?.tipoError = apiError.authorizerResponseCode ?? "-1"
            } else {
                self.transactionResponseObj?.msgError = apiError.message ?? "Desconocido"
                self.transactionResponseObj?.tipoError = apiError.error ?? "-1"
            }
            
            // Invoke result page HERE.
            var summaryValues:[SummaryItem] = []
            if let transactionResponseObj = self.transactionResponseObj {
                summaryValues.append(SummaryItem(name: "Tipo de error",value: transactionResponseObj.tipoError ))
                summaryValues.append(SummaryItem(name: "Mensaje de error",value: transactionResponseObj.msgError  ))
            }
            self.sendSummary(success: false, resultMsgTxt: "¡Ups, ocurrio un problema aplicando el pago!", summaryValues: summaryValues, addDelegate: true)
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            
            self.inputSrvName.isEnabled = true
            self.inputSrvReference.isEnabled = true
            self.inputSrvAmount.isEnabled = true
            self.submitBtn.isEnabled = true
            self.submitBtn.isHidden = false
            self.indicator.stopAnimating()
            self.indicator.isHidden = true
            //self.showAlert(message: "Ocurrio un error invocando el servicio. Verifique su conexión a internet.")
            
            self.transactionResponseObj = TransactionResponseObj()
            self.transactionResponseObj?.msgError = response.debugDescription
            self.transactionResponseObj?.tipoError = "\(response?.statusCode ?? -1)"
            
            // Invoke result page HERE.
            var summaryValues:[SummaryItem] = []
            if let transactionResponseObj = self.transactionResponseObj {
                summaryValues.append(SummaryItem(name: "Tipo de error",value: transactionResponseObj.tipoError ))
                summaryValues.append(SummaryItem(name: "Mensaje de error",value: transactionResponseObj.msgError  ))
            }
            self.sendSummary(success: false, resultMsgTxt: "¡Ups, ocurrio un problema aplicando el pago!", summaryValues: summaryValues, addDelegate: true)
        }
        return RestCallback<TransactionResponse>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    private func sendSummary(success: Bool, resultMsgTxt: String, summaryValues: [SummaryItem], addDelegate: Bool) {
        if(parentController != nil) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let ptarget = storyboard.instantiateViewController(withIdentifier: "abstractResultVC") as! AbstractResultViewController
            ptarget.convert(to: PaymentServicesResultViewController.self)
            let target:PaymentServicesResultViewController = ptarget as! PaymentServicesResultViewController
            
            target.transactionResponseObj = self.transactionResponseObj
            target.resultTitleTxt = "Pago de Servicios"
            target.repeatButtonTxt = "Realizar otro Pago"
            target.fragmentSection = FragmentSection.PAGO_SERVICIOS
            //target.targetAction = FragmentSection.PAGO_SERVICIOS.rawValue
            target.postOperationAction = target as PostOperationAction
            target.success = success
            target.resultMsgTxt = resultMsgTxt
            target.summaryValues = summaryValues
            
            parentController?.onSectionChange(target: target, fragmentSection: FragmentSection.PAGO_SERVICIOS)
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
