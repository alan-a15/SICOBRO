//
//  SetPinViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 05/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
//import VKPinCodeView
import Alamofire

class SetPinViewController: AbstractAuthenticationViewController {

    @IBOutlet weak var pinViewContainer: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var confirmationLabel: UILabel!
    
    private var pinView = VKPinCodeView()
    
    private var firstPin : String?
    private var currentValuePin : String?
    private var requestConfirmation : Bool = false
    
    // Labels
    
    @IBOutlet weak var contraint0: UILabel!
    @IBOutlet weak var contraint5: UILabel!
    @IBOutlet weak var contraint6: UILabel!
    
    @IBOutlet weak var backButtonHeader: UIImageView!
    
    var isPwdChange = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.text = "Crea un password de 4 dígitos,\nrecuerda que debe ser fácil de recordar\nya que será tu clave de ingreso a la aplicación."
        confirmationLabel.alpha = 0.0
        
        PIN_ERRORS.ERR_LENGHT.errorId = contraint0
        PIN_ERRORS.ERR_FIRST_CAMEL_LETTER.errorId = contraint5
        PIN_ERRORS.ERR_LAST_THREE_NUMBERS.errorId = contraint6
        
        pinView.translatesAutoresizingMaskIntoConstraints = false
        
        pinView.onBeginEditing = beginEditingClosure
        pinView.onCodeDidChange = changePin
        pinView.onComplete = completeClosure
        pinView.shakeOnError = true
        pinView.maskText = true
        pinView.resetAfterError = ResetType.afterError(1.0)
        pinView.keyBoardType = UIKeyboardType.alphabet
        
        pinView.length = 4
        pinViewContainer.addSubview(pinView)
        pinView.leadingAnchor.constraint(equalTo: pinViewContainer.leadingAnchor, constant: 40).isActive = true
        pinView.trailingAnchor.constraint(equalTo: pinViewContainer.trailingAnchor, constant: -40).isActive = true
        pinView.centerYAnchor.constraint(equalTo: pinViewContainer.centerYAnchor).isActive = true
        pinView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pinView.onSettingStyle = { BorderStyle(masked: true)}
        //pinView.becomeFirstResponder()
    
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(back))
        backButtonHeader.addGestureRecognizer(tap1)
        backButtonHeader.isUserInteractionEnabled = true
    
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(appMovedToForeground),
                                       name: UIApplication.willEnterForegroundNotification, object: nil)
    
        notificationCenter.addObserver(self, selector: #selector(appMovedToBackground),
                                       name: UIApplication.didEnterBackgroundNotification, object: nil)
    }

    @objc func appMovedToBackground() {
        print("App moved to Background!")
        self.view.endEditing(true)
    }

    @objc func appMovedToForeground() {
        print("App moved to Foreground!")
        // This should validate the session when the view appears.
        if( !sessionManager.validateLastLoginCredentials() ) {
            self.validateSessions(forwardToInitial: false, destroyCurrentView: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("SetPinViewController: On viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func beginEditingClosure() {
        // Hide errors if showed
        currentValuePin = ""
        if (!requestConfirmation) {
            restorePinErrors()
        }
    }
    
    private func changePin(code:String) {
        // We need validate it here?
        // Probably to filter the non-accepted chars
        currentValuePin = code
    }
    
    private func completeClosure(code:String, pinView :VKPinCodeView) {
        currentValuePin = code
        
    }

    
    @IBAction func submitPin(_ sender: Any) {
        validatePin()
    }
    
    private func restorePinErrors() {
        PIN_ERRORS.errorsAsArray()
            .filter { $0.errorId != nil }
            .map { $0.errorId?.textColor = UIColor.black }
        
        if (self.confirmationLabel.alpha == 1.0) {
            UIView.transition(with: self.confirmationLabel, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.confirmationLabel.alpha = 0.0
            }, completion: nil)
        }
    }
    
    private func validatePin() {
        restorePinErrors()
        
        guard let currentValuePin = currentValuePin, !currentValuePin.isEmpty else {
            showAlert(message: "Debe introducir un PIN")
            pinView.isError = true
            requestConfirmation = false
            firstPin = ""
            self.currentValuePin = ""
            return
        }

        let errorCodes = validatePin(pin: currentValuePin)
        if (errorCodes > 0) {
            retrievePinErrors(codes: errorCodes)
            pinView.isError = true
            requestConfirmation = false
            firstPin = ""
            self.currentValuePin = ""
            showAlert(message: "El PIN no es válido")
            return
        }
        

            if(requestConfirmation) {
                if(currentValuePin == firstPin ) {
                    // Save Pin Asyncronouesly in Backend
                    
                    //var mAuthTask = SetPinTask(pinStr)
                    //mAuthTask!!.execute(null as Void?)
                    
                    //sessionManager.setUserProperty(key: SessionManager.Key.REQUIRED_RESET_PWD, value: false)
                    //forwardHomePage()
                    var request = ChangePasswordRequest()
                    request.password = currentValuePin
                    authenticationService.changePassword(request: request, callback: getChangePwdCallback())
                    
                } else {
                    requestConfirmation = false
                    firstPin = ""
                    self.currentValuePin = ""
                    pinView.isError = true
                    showAlert(message: "Los passwords no coinciden")
                }
            } else {
                // Show label with password confirmation
                /*
                pwdConfirmation.text = getString(R.string.pin_confirmation)
                if(pwdConfirmation.alpha == 0.0f) {
                    pwdConfirmation.animate().alpha(1.0f)
                }
                */
                if (self.confirmationLabel.alpha == 0.0) {
                    UIView.transition(with: self.confirmationLabel, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                        self.confirmationLabel.alpha = 1.0
                    }, completion: nil)
                }
                
                requestConfirmation = true
                firstPin = currentValuePin
                self.currentValuePin = ""
                pinView.resetCode()
                // Reset pin vlaue
                //inputPin.setText("")
            }
        
    }
    
    func getChangePwdCallback() ->RestCallback<String> {
        let onResponse : ((String?) -> ())? = { response in
            debugPrint("response \(String(describing: response))")
            
            ////////////////////////////////////////////////////////////////////////////////
            self.sessionManager.setUserProperty(key: SessionManager.Key.REQUIRED_RESET_PWD, value: false)
            self.forwardHomePage()
            ////////////////////////////////////////////////////////////////////////////////
        }
        
        let apiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error enviando recibo - Message "
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            debugPrint("\(smsg): \(msg)")
            self.showAlert(message: "Ocurrio un error actualizando password.")
        }
        
        let onFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            debugPrint("error \(String(describing: error))")
            debugPrint("errorDescription \(String(describing: error?.errorDescription))")
            debugPrint("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            debugPrint("destinationURL \(String(describing: error?.destinationURL))")
            
            debugPrint("response \(String(describing: response))")
            debugPrint("statusCode \(String(describing: response?.statusCode))")
            
            self.showAlert(message: "Ocurrio un error actualizando password. Verifique su conexión a internet. - \(String(describing: error?.errorDescription))")
        }
        return RestCallback<String>(onResponse: onResponse, onApiError: apiError, onFailure: onFailure)
    }
    
    private func forwardHomePage(storyboard: String = "Main") {
        /*
        let loginStoryboard = UIStoryboard(name: storyboard , bundle: nil)
        let homePage = loginStoryboard.instantiateViewController(withIdentifier: "homePage") as! HomePageViewController
        //self.present(homePage, animated: true)
        self.navigationController!.pushViewController(homePage, animated: true)
         */
        
        goToSiCobroHomePage()
        var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
        navStackArray.remove(at: navStackArray.count - 2)
        self.navigationController?.setViewControllers(navStackArray, animated: true)
        
    }
    
    override func performSegue(withIdentifier identifier: String, sender: Any?) {
        super.performSegue(withIdentifier: identifier, sender: sender)
        
        var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
         
        navStackArray.remove(at: navStackArray.count - 2)
        
        self.navigationController?.setViewControllers(navStackArray, animated: true)
    }
    
    private func retrievePinErrors(codes:Int) {
        PIN_ERRORS.errorsAsArray().filter({ (PIN_ERRORS) -> Bool in
            ((codes & PIN_ERRORS.code) > 0) &&
                (PIN_ERRORS.honor) &&
                (PIN_ERRORS.errorId != nil)
        }).map {
             $0.errorId?.textColor = UIColor.red
        }
    }
    
    /**
     * Perform validations over the pin:
     * * (1)  Lenght = 4
     * * (2)  At least 1 Number
     * * (4)  At least 1 Character
     * * (8)  Not duplicate characters
     * * (16)  Not use consecutive numbers/characters
     */
    func validatePin(pin:String) -> Int {
        var errorCode : Int = 0
        let lenght = pin.count

        // Validate lenght
        if (PIN_ERRORS.ERR_LENGHT.honor) {
            if (lenght != 4) {
                errorCode += 1
                return errorCode
            }
        }
        
        // Validate there are at least 1 number
        if (PIN_ERRORS.ERR_NUMBERS.honor) {
            if ( pin.filter { (Character) -> Bool in
                    Character.isNumber }.isEmpty ) {
                errorCode += 2
            }
        }

        // Validate there are at least 1 character
        if (PIN_ERRORS.ERR_CHARS.honor) {
            if ( pin.filter { (Character) -> Bool in
                    Character.isLetter }.isEmpty ) {
                errorCode += 4
            }
        }

        // Validate non duplicates
        if (PIN_ERRORS.ERR_DUPLICATE.honor) {
            for i in pin.indices {
                var li = pin.lastIndex(of: pin[i])
                if (li != i) {
                    errorCode += 8
                    break
                }
            }
        }

        // Validate non-consecutive characters
        if (PIN_ERRORS.ERR_CONSECUTIVES.honor) {
            var si = 0
            var ei = si + 1
            
            repeat {
                var startIndex = pin.index(pin.startIndex, offsetBy: si)
                var endIndex = pin.index(pin.startIndex, offsetBy: ei)
                
                var ec = pin[endIndex]
                var sc = pin[startIndex]
                
                var r = ec.hashValue - sc.hashValue
                if (r == 1) {
                    errorCode += 16
                    break
                }
                si += 1
                ei = si + 1
            } while (si < lenght)
        }

        // Validate first letter is Camel
        if (PIN_ERRORS.ERR_FIRST_CAMEL_LETTER.honor) {
            if(!pin[pin.startIndex].isCased) {
                errorCode += PIN_ERRORS.ERR_FIRST_CAMEL_LETTER.code
            } else {
                errorCode += 0
            }
        }

        // Validate last 3 characters as Numbers
        if (PIN_ERRORS.ERR_LAST_THREE_NUMBERS.honor) {
            
            if (
                pin.indices.filter {
                    $0 != pin.startIndex && pin[$0].isNumber
                }.isEmpty
                ) {
                errorCode += PIN_ERRORS.ERR_LAST_THREE_NUMBERS.code
            }
        }

        return errorCode
    }
}

struct PIN_ERRORS : Equatable {
    var code: Int = 0
    var errorId: UILabel?
    var honor: Bool = false
    
    public init(code: Int, honor: Bool) {
        self.code = code
        self.honor = honor
    }
    
    static var ERR_LENGHT:PIN_ERRORS = PIN_ERRORS(code:1, honor:true)
    static let ERR_NUMBERS:PIN_ERRORS = PIN_ERRORS(code: 2, honor: false)
    static let ERR_CHARS:PIN_ERRORS = PIN_ERRORS(code: 4,honor: false)
    static let ERR_DUPLICATE:PIN_ERRORS = PIN_ERRORS(code: 8, honor: false)
    static let ERR_CONSECUTIVES:PIN_ERRORS = PIN_ERRORS(code: 16, honor: false)
    static var ERR_FIRST_CAMEL_LETTER:PIN_ERRORS = PIN_ERRORS(code: 32, honor: true)
    static var ERR_LAST_THREE_NUMBERS:PIN_ERRORS = PIN_ERRORS(code: 64, honor: true)
    
    static func errorsAsArray() -> [PIN_ERRORS] {
        var array:[PIN_ERRORS] = []
        array.append(ERR_LENGHT)
        array.append(ERR_NUMBERS)
        array.append(ERR_CHARS)
        array.append(ERR_DUPLICATE)
        array.append(ERR_CONSECUTIVES)
        array.append(ERR_FIRST_CAMEL_LETTER)
        array.append(ERR_LAST_THREE_NUMBERS)
        return array
    }
}
