//
//  PinLoginViewController.swift
//  zorro-ios-app11
//
//  Created by José Antonio Hijar on 05/04/20.
//  Copyright © 2020 José Antonio Hijar. All rights reserved.
//

import UIKit
//import PinEntryField
//import VKPinCodeView
import Alamofire

class PinLoginViewController: AbstractAuthenticationViewController {

    @IBOutlet weak var pinViewContainer: UIView!
    @IBOutlet weak var usernameTxt: UILabel!
    @IBOutlet weak var changePasswordConfirm: UIView!
    @IBOutlet weak var backButtonHeader: UIImageView!
    
    @IBOutlet weak var btnLogin: CustomRoundedButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var isTimedOut : Bool = false
    private var currentValuePin : String?
    
    let pinView = VKPinCodeView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.isHidden = false
        indicator.hidesWhenStopped = true
        
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(confirmChangePassword))
        changePasswordConfirm?.addGestureRecognizer(tap)
        changePasswordConfirm?.isUserInteractionEnabled = true
        
        if let user:UserInfoLoginResponse? = sessionManager.loadUserSession() {
            usernameTxt.text = user?.user
        }
        
        if( isTimedOut ) {
            self.showAlert(message: "La sesión expiró")
        }
        
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
        print("PinLoginViewController: On viewWillDisappear")
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //func didFinishInput(_ inputView: CodeView, didFinishWith text: String) {
    //    currentValuePin = text
    //}
    private func beginEditingClosure() {
        // Hide errors if showed
        currentValuePin = ""
    }
    
    private func changePin(code:String) {
        // We need validate it here?
        // Probably to filter the non-accepted chars
        currentValuePin = code
    }
    
    private func completeClosure(code:String, pinView :VKPinCodeView) {
        currentValuePin = code
        
    }
    
    @IBAction func submitLogin(_ sender: UIButton) {
        let user:UserInfoLoginResponse? = sessionManager.loadUserSession()
        let request : LoginRequest = LoginRequest()
        
        btnLogin.isHidden = true
        indicator.startAnimating()
        
        print("redId \(user?.redId)")
        print("storeUsername \(user?.user)")
        
        request.redId = user?.redId
        request.storePassword = currentValuePin
        request.storeUsername = user?.storeUsername
        
        let deviceInfo = DeviceUtil.getDeviceInfo()
        request.deviceId = deviceInfo.deviceId
        request.deviceBrand = deviceInfo.deviceBrand
        request.deviceModel = deviceInfo.deviceModel
        request.deviceOSVersion = deviceInfo.deviceOSVersion
        
        authenticationService.performCredentialLogin(loginReq: request, callback: createLoginCallback())
    }
    
    private func createLoginCallback() -> RestCallback<LoginResponse> {
        let loginOnResponse : ((LoginResponse?) -> ())? = { response in
            self.indicator.stopAnimating()
            self.btnLogin.isHidden = false
            
            print("response \(response)")
            print("actionRequired \(String(describing: response?.actionRequired))")
            print("maskedEmail \(response?.maskedEmail)")
            print("sessionToken \(response?.sessionToken)")
            
            let user:UserInfoLoginResponse? = self.sessionManager.loadUserSession()
            let userInfo : UserInfoLoginResponse = UserInfoLoginResponse()
            if( response != nil ) {
                userInfo.redId = user?.redId ?? "001426018"
                userInfo.addDataFromLoginResponse(loginData: response!)
                // Create logged user in session
                self.sessionManager.createInitialUserSession(user: userInfo)
                // Store Session Timeout from JANO
                self.authenticationService.getSessionTimeout(callback: self.createTimeoutCallback())
            }
        
             // TO-DO: Adapt this code
             /*
             /**
             * This case should not occur, but just in case we're validating it because if the
             * password is emailed it is most probably that some login data like redId, and/or
             * username came null, which could be risky for the support of this case. So, we are
             * forcing customer uses the password sent via email then we will ensure the login data
             * is not null.
             */
             if (sessionManager.isNewSiCobroUser()) {
                 showWelcomeToSiCobroDialog()
                 return
             }
             */

            self.goToSiCobroHomePage()
            var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
            navStackArray.remove(at: navStackArray.count - 2)
            self.navigationController?.setViewControllers(navStackArray, animated: true)
        }
        
        let loginApiError : ((ApiError)->())? =  { apiError in
            self.indicator.stopAnimating()
            self.btnLogin.isHidden = false
            
            let smsg = "Ocurrio un error en Login"
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            self.showAlert(message: "\(smsg): \(msg)")
            self.pinView.isError = true
            //self.pinView.deleteBackward()
            //self.pinView.deleteBackward()
            //self.pinView.deleteBackward()
            //self.pinView.deleteBackward()
        }
        
        let loginOnFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            self.indicator.stopAnimating()
            self.btnLogin.isHidden = false
            
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            self.showAlert(message: "Error ocurred for login: \(String(describing: error?.errorDescription))")
            self.pinView.isError = true
        }
        return RestCallback<LoginResponse>(onResponse: loginOnResponse, onApiError: loginApiError, onFailure: loginOnFailure)
    }
    
    /*
     *
     */
    private func createTimeoutCallback() -> RestCallback<Int> {
        let timeoutOnRespose : ((Int?) -> ())? = { response in
            print("response \(String(describing: response))")
            self.sessionManager.setTimeoutSession(timeoutInSeconds: response ?? 300)
        }
        
        let timeoutApiError : ((ApiError)->())? =  { apiError in
            let smsg = "Ocurrio un error obteniendo timeout desde Jano"
            guard let msg = apiError.message else {
                self.showAlert(message: smsg)
                return
            }
            print("\(smsg): \(msg)")
            self.sessionManager.setTimeoutSession()
        }
        
        let timeoutOnFailure : ((AFError?,HTTPURLResponse?)->())? = { (error, response) in
            print("error \(String(describing: error))")
            print("errorDescription \(String(describing: error?.errorDescription))")
            print("failedStringEncoding \(String(describing: error?.failedStringEncoding))")
            print("destinationURL \(String(describing: error?.destinationURL))")
            
            print("response \(String(describing: response))")
            print("statusCode \(String(describing: response?.statusCode))")
            self.sessionManager.setTimeoutSession()
        }
        
        return RestCallback<Int>(onResponse: timeoutOnRespose, onApiError: timeoutApiError, onFailure: timeoutOnFailure)
    }
    
    @objc func goHomePage() {
        let loginStoryboard = UIStoryboard(name: "Main" , bundle: nil)
        let homePage = loginStoryboard.instantiateViewController(withIdentifier: "SiCobroViewController") as! HomePageViewController
        
        //self.navigationController!.pushViewController(homePage, animated: true)
        var navStackArray: [UIViewController]! = self.navigationController?.viewControllers
        navStackArray.remove(at: navStackArray.count - 1)
        navStackArray.append(homePage)
        self.navigationController?.setViewControllers(navStackArray, animated: true)
    }
}
